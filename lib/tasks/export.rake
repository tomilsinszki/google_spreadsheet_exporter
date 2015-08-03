require "google/api_client"
require "google_drive"
require "net/http"

namespace :export do
  @sum_answer_count = {}
  @answer_count_for_ratable = {}
  @rateable_names = {}
  @question_texts = {}
  @answer_texts = {}
  @spreadsheet = nil
  @start_date_string = Time.now.strftime("%Y-%m-01 00:00:00")
  @end_date_string = 1.day.ago.strftime("%Y-%m-%d 23:59:59")
  @rateable_collection_id = 0
  @current_line_number = 1

  desc "fetch data for current month and update spreadsheet"
  task current_month: :environment do
    @start_date_string = (ENV['start_date_string'] == nil) ? @start_date_string : ENV['start_date_string']
    @end_date_string = (ENV['end_date_string'] == nil) ? @end_date_string : ENV['end_date_string']
    @rateable_collection_id = ENV['rateable_collection_id'].to_i
    @spreadsheet_key = ENV['spreadsheet_key']
    fetch_data_and_update_spreadsheet
  end

  def fetch_data_and_update_spreadsheet
    puts "Start date: #{@start_date_string}"
    puts "End date: #{@end_date_string}"
    puts "Rateable collection id: #{@rateable_collection_id}"
    puts

    setup_connection_to_spreadsheet
    fetch_questions_and_answer_counts
    fetch_all_answer_texts
    update_google_spreadsheet
  end

  def setup_connection_to_spreadsheet
    client = Google::APIClient.new
    auth = client.authorization
    auth.client_id = Rails.application.config.x.google_api_client_id
    auth.client_secret = Rails.application.config.x.google_api_client_secret

    auth.scope = [
      "https://www.googleapis.com/auth/drive",
      "https://spreadsheets.google.com/feeds/"
    ]
    auth.redirect_uri = "https://www.rateme.hu/oauth2callback"
    print("1. Open this page:\n%s\n\n" % auth.authorization_uri)
    print("2. Enter the authorization code shown in the page: ")
    auth.code = $stdin.gets.chomp
    auth.fetch_access_token!
    access_token = auth.access_token

    session = GoogleDrive.login_with_oauth(access_token)

    @spreadsheet = session.spreadsheet_by_key(@spreadsheet_key).worksheets[0]
  end

  def fetch_questions_and_answer_counts
    sql = "SELECT
        rateable.id AS rateable_id,
        rateable.name AS rateable_name,
        sub_rating_question.id AS question_id,
        sub_rating_question.text AS question_text,
        sub_rating_answer_type.id AS answer_type_id,
        sub_rating_answer.id AS answer_id,
        sub_rating_answer.text AS answer_text,
        COUNT(sub_rating_answer.id) AS answer_count
    FROM rateable
    LEFT JOIN rating ON rating.rateable_id=rateable.id
    LEFT JOIN sub_rating ON sub_rating.rating_id=rating.id
        AND '#{@start_date_string}' <= rating.created
        AND rating.created <= '#{@end_date_string}'
    LEFT JOIN sub_rating_answer ON sub_rating.answer_id=sub_rating_answer.id
    LEFT JOIN sub_rating_answer_type ON sub_rating_answer_type.id=sub_rating_answer.type_id
    LEFT JOIN sub_rating_question ON sub_rating_answer.question_id=sub_rating_question.id
    WHERE
        rateable.collection_id=#{@rateable_collection_id} AND
        sub_rating.id IS NOT NULL AND
        rateable.is_active=1
    GROUP BY rateable.id, sub_rating_answer.id
    ORDER BY sub_rating_question.text, rateable.name, sub_rating_answer_type.name;"

    rows = ActiveRecord::Base.connection.execute(sql)

    rows.each(:as => :hash) do |row|
      question_id = row["question_id"].to_i
      rateable_id = row["rateable_id"].to_i
      answer_id = row["answer_id"].to_i
      answer_count = row["answer_count"].to_i

      if !@sum_answer_count.has_key?(question_id)
        @sum_answer_count[question_id] = {}
      end
      if !@sum_answer_count[question_id].has_key?(answer_id)
        @sum_answer_count[question_id][answer_id] = 0
      end
      @sum_answer_count[question_id][answer_id] += answer_count

      if !@answer_count_for_ratable.has_key?(question_id)
        @answer_count_for_ratable[question_id] = {}
      end
      if !@answer_count_for_ratable[question_id].has_key?(rateable_id)
        @answer_count_for_ratable[question_id][rateable_id] = {}
      end
      @answer_count_for_ratable[question_id][rateable_id][answer_id] = answer_count

      if !@rateable_names.has_key?(question_id)
        @rateable_names[question_id] = {}
      end
      @rateable_names[question_id][rateable_id] = row["rateable_name"]

      if !@answer_texts.has_key?(question_id)
        @answer_texts[question_id] = {}
      end
      @answer_texts[question_id][answer_id] = row["answer_text"]

      @question_texts[question_id] = row["question_text"]
    end
  end

  def fetch_all_answer_texts
    @question_texts.each do |question_id, question_text|
      sql = 
        "SELECT
          sub_rating_question.id AS question_id,
          sub_rating_question.text AS question_text,
          sub_rating_answer.id AS answer_id,
          sub_rating_answer.text AS answer_text
        FROM sub_rating_question
        LEFT JOIN sub_rating_answer ON sub_rating_question.id=sub_rating_answer.question_id
        WHERE 
          sub_rating_question.id=#{question_id}"
      
      rows = ActiveRecord::Base.connection.execute(sql)

      rows.each(:as => :hash) do |row|
        question_id = row["question_id"].to_i
        answer_id = row["answer_id"].to_i
        
        if !@sum_answer_count.has_key?(question_id)
          @sum_answer_count[question_id] = {}
        end
        if !@sum_answer_count[question_id].has_key?(answer_id)
          if 0 < row["answer_text"].to_s.length
            @sum_answer_count[question_id][answer_id] = 0
          end
        end

        if !@answer_texts[question_id].has_key?(answer_id)
          if 0 < row["answer_text"].to_s.strip.length
            @answer_texts[question_id][answer_id] = row["answer_text"]
          end
        end
      end
    end
  end

  def update_google_spreadsheet
    l1 = @current_line_number
    c1 = 1
    @question_texts.each do |question_id, question_text|
      @spreadsheet[l1+1, c1] = @question_texts[question_id]

      answer_index = 0
      @answer_texts[question_id].each do |answer_id, answer_text|
        @spreadsheet[l1, c1+answer_index+1] = answer_text
        @spreadsheet[l1+1, c1+answer_index+1] = @sum_answer_count[question_id][answer_id]

        rateable_index = 0
        @rateable_names[question_id].each do |rateable_id, rateable_name|
          @spreadsheet[l1+rateable_index+2, 1] = rateable_name
          @spreadsheet[l1+rateable_index+2, c1+answer_index+1] = @answer_count_for_ratable[question_id][rateable_id][answer_id].to_i
          rateable_index += 1
        end

        answer_index += 1
      end

      l1 += (@rateable_names[question_id].length + 3)
    end
    
    @spreadsheet.save()
  end
end
