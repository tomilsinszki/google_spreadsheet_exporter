# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 0) do

  create_table "company", force: :cascade do |t|
    t.string "name",                               limit: 511,                           null: false
    t.text   "emailBodySchema",                    limit: 4294967295
    t.string "ratingPageBackgroundColor",          limit: 6,          default: "E8DDCB", null: false
    t.string "ratingPageFontColor",                limit: 6,          default: "033649", null: false
    t.string "ratingPageStarsSubtitleFontColor",   limit: 6,          default: "CDB380", null: false
    t.string "ratingPageCancelSubratingFontColor", limit: 6,          default: "031634", null: false
    t.string "ratingPromotionPrizeName",           limit: 511
    t.string "ratingPromotionRulesURL",            limit: 255
    t.string "ratingEmailBackgroundColor",         limit: 6,          default: "FFFFFF", null: false
    t.string "ratingEmailFontColor",               limit: 6,          default: "000000", null: false
  end

  create_table "contact", force: :cascade do |t|
    t.integer  "client_id",                         limit: 4
    t.integer  "rateable_id",                       limit: 4
    t.integer  "rating_id",                         limit: 4
    t.string   "email_address",                     limit: 255, null: false
    t.string   "first_name",                        limit: 255
    t.string   "last_name",                         limit: 255, null: false
    t.string   "rate_token",                        limit: 255
    t.datetime "contact_happened_at",                           null: false
    t.datetime "sent_email_at"
    t.datetime "client_flagged_email_as_flawed_at"
  end

  add_index "contact", ["client_id"], name: "IDX_4C62E63819EB6921", using: :btree
  add_index "contact", ["rate_token"], name: "UNIQ_4C62E638CF77B818", unique: true, using: :btree
  add_index "contact", ["rateable_id"], name: "IDX_4C62E638676F61C9", using: :btree
  add_index "contact", ["rating_id"], name: "UNIQ_4C62E638A32EFC6", unique: true, using: :btree

  create_table "ext_log_entries", force: :cascade do |t|
    t.string   "action",       limit: 8,          null: false
    t.datetime "logged_at",                       null: false
    t.string   "object_id",    limit: 64
    t.string   "object_class", limit: 255,        null: false
    t.integer  "version",      limit: 4,          null: false
    t.text     "data",         limit: 4294967295
    t.string   "username",     limit: 255
  end

  add_index "ext_log_entries", ["logged_at"], name: "log_date_lookup_idx", using: :btree
  add_index "ext_log_entries", ["object_class"], name: "log_class_lookup_idx", using: :btree
  add_index "ext_log_entries", ["object_id", "object_class", "version"], name: "log_version_lookup_idx", using: :btree
  add_index "ext_log_entries", ["username"], name: "log_user_lookup_idx", using: :btree

  create_table "ext_translations", force: :cascade do |t|
    t.string "locale",       limit: 8,          null: false
    t.string "object_class", limit: 255,        null: false
    t.string "field",        limit: 32,         null: false
    t.string "foreign_key",  limit: 64,         null: false
    t.text   "content",      limit: 4294967295
  end

  add_index "ext_translations", ["locale", "object_class", "field", "foreign_key"], name: "lookup_unique_idx", unique: true, using: :btree
  add_index "ext_translations", ["locale", "object_class", "foreign_key"], name: "translations_lookup_idx", using: :btree

  create_table "identifier", force: :cascade do |t|
    t.string   "qr_code_url",        limit: 255, null: false
    t.string   "alphanumeric_value", limit: 255, null: false
    t.datetime "created",                        null: false
    t.datetime "updated",                        null: false
  end

  add_index "identifier", ["alphanumeric_value"], name: "UNIQ_772E836AA32CFD30", unique: true, using: :btree
  add_index "identifier", ["qr_code_url"], name: "UNIQ_772E836A72084AB0", unique: true, using: :btree

  create_table "image", force: :cascade do |t|
    t.string "path", limit: 255, null: false
  end

  create_table "quiz", force: :cascade do |t|
    t.integer  "rateable_id",     limit: 4, null: false
    t.datetime "created",                   null: false
    t.integer  "elapsed_seconds", limit: 4, null: false
  end

  add_index "quiz", ["rateable_id"], name: "IDX_A412FA92676F61C9", using: :btree

  create_table "quiz_question", force: :cascade do |t|
    t.integer  "rateable_collection_id", limit: 4,   null: false
    t.string   "text",                   limit: 255, null: false
    t.string   "correct_answer_text",    limit: 255, null: false
    t.datetime "created",                            null: false
    t.datetime "updated",                            null: false
    t.datetime "deleted"
  end

  add_index "quiz_question", ["rateable_collection_id"], name: "IDX_6033B00B2ABDBC3E", using: :btree
  add_index "quiz_question", ["text", "rateable_collection_id"], name: "unique_question", unique: true, using: :btree

  create_table "quiz_reply", force: :cascade do |t|
    t.integer "quiz_id",               limit: 4, null: false
    t.integer "question_id",           limit: 4, null: false
    t.integer "wrong_given_answer_id", limit: 4
  end

  add_index "quiz_reply", ["question_id"], name: "IDX_1DBBF601E27F6BF", using: :btree
  add_index "quiz_reply", ["quiz_id"], name: "IDX_1DBBF60853CD175", using: :btree
  add_index "quiz_reply", ["wrong_given_answer_id"], name: "IDX_1DBBF6091C0F811", using: :btree

  create_table "quiz_wrong_answer", force: :cascade do |t|
    t.integer  "question_id", limit: 4,   null: false
    t.string   "text",        limit: 255, null: false
    t.datetime "created",                 null: false
    t.datetime "deleted"
  end

  add_index "quiz_wrong_answer", ["question_id"], name: "IDX_8B511E6C1E27F6BF", using: :btree
  add_index "quiz_wrong_answer", ["text", "question_id"], name: "unique_wrong_answer", unique: true, using: :btree

  create_table "rateable", force: :cascade do |t|
    t.integer  "identifier_id",              limit: 4
    t.integer  "image_id",                   limit: 4
    t.integer  "collection_id",              limit: 4
    t.integer  "rateable_user_id",           limit: 4
    t.string   "name",                       limit: 255, null: false
    t.string   "type_name",                  limit: 255, null: false
    t.boolean  "is_reachable_via_telephone",             null: false
    t.boolean  "is_active",                              null: false
    t.datetime "created",                                null: false
    t.datetime "updated",                                null: false
  end

  add_index "rateable", ["collection_id"], name: "IDX_5BAE876B514956FD", using: :btree
  add_index "rateable", ["identifier_id"], name: "UNIQ_5BAE876BEF794DF6", unique: true, using: :btree
  add_index "rateable", ["image_id"], name: "UNIQ_5BAE876B3DA5256D", unique: true, using: :btree
  add_index "rateable", ["rateable_user_id"], name: "UNIQ_5BAE876B7FC3D43D", unique: true, using: :btree

  create_table "rateable_collection", force: :cascade do |t|
    t.integer  "identifier_id",      limit: 4
    t.integer  "image_id",           limit: 4
    t.integer  "company_id",         limit: 4
    t.integer  "question_order_id",  limit: 4,   null: false
    t.string   "name",               limit: 255, null: false
    t.string   "foreign_url",        limit: 255
    t.datetime "created",                        null: false
    t.datetime "updated",                        null: false
    t.integer  "max_question_count", limit: 4
  end

  add_index "rateable_collection", ["company_id"], name: "IDX_CC0020A0979B1AD6", using: :btree
  add_index "rateable_collection", ["identifier_id"], name: "UNIQ_CC0020A0EF794DF6", unique: true, using: :btree
  add_index "rateable_collection", ["image_id"], name: "UNIQ_CC0020A03DA5256D", unique: true, using: :btree
  add_index "rateable_collection", ["name"], name: "UNIQ_CC0020A05E237E06", unique: true, using: :btree
  add_index "rateable_collection", ["question_order_id"], name: "IDX_CC0020A0EE97DD34", using: :btree

  create_table "rateable_collection_owner", id: false, force: :cascade do |t|
    t.integer "collection_id", limit: 4, null: false
    t.integer "user_id",       limit: 4, null: false
  end

  add_index "rateable_collection_owner", ["collection_id"], name: "IDX_5305B2E514956FD", using: :btree
  add_index "rateable_collection_owner", ["user_id"], name: "IDX_5305B2EA76ED395", using: :btree

  create_table "rating", force: :cascade do |t|
    t.string   "email",             limit: 255
    t.string   "rating_ip_address", limit: 255
    t.integer  "rateable_id",       limit: 4
    t.integer  "rating_user_id",    limit: 4
    t.integer  "stars",             limit: 4,   null: false
    t.datetime "created",                       null: false
    t.datetime "updated",                       null: false
  end

  add_index "rating", ["rateable_id"], name: "IDX_D8892622676F61C9", using: :btree
  add_index "rating", ["rating_user_id"], name: "IDX_D889262244222AED", using: :btree

  create_table "role", force: :cascade do |t|
    t.string "name", limit: 30, null: false
    t.string "role", limit: 20, null: false
  end

  add_index "role", ["role"], name: "UNIQ_57698A6A57698A6A", unique: true, using: :btree

  create_table "sub_rating", force: :cascade do |t|
    t.integer  "answer_id", limit: 4, null: false
    t.integer  "rating_id", limit: 4, null: false
    t.datetime "created",             null: false
    t.datetime "updated",             null: false
  end

  add_index "sub_rating", ["answer_id"], name: "IDX_6AD8696EAA334807", using: :btree
  add_index "sub_rating", ["rating_id"], name: "IDX_6AD8696EA32EFC6", using: :btree

  create_table "sub_rating_answer", force: :cascade do |t|
    t.integer  "question_id", limit: 4,   null: false
    t.integer  "type_id",     limit: 4,   null: false
    t.string   "text",        limit: 255, null: false
    t.boolean  "is_enabled",              null: false
    t.datetime "created",                 null: false
    t.datetime "updated",                 null: false
  end

  add_index "sub_rating_answer", ["question_id"], name: "IDX_3A82E7731E27F6BF", using: :btree
  add_index "sub_rating_answer", ["type_id"], name: "IDX_3A82E773C54C8C93", using: :btree

  create_table "sub_rating_answer_type", force: :cascade do |t|
    t.integer "question_type_id", limit: 4,   null: false
    t.string  "name",             limit: 255, null: false
  end

  add_index "sub_rating_answer_type", ["question_type_id"], name: "IDX_E339D53BCB90598E", using: :btree

  create_table "sub_rating_question", force: :cascade do |t|
    t.integer  "type_id",       limit: 4
    t.integer  "collection_id", limit: 4,   null: false
    t.integer  "sequence",      limit: 4
    t.string   "title",         limit: 255, null: false
    t.string   "text",          limit: 255, null: false
    t.integer  "target",        limit: 4,   null: false
    t.datetime "created",                   null: false
    t.datetime "updated",                   null: false
    t.datetime "deleted"
  end

  add_index "sub_rating_question", ["collection_id"], name: "IDX_F2718C96514956FD", using: :btree
  add_index "sub_rating_question", ["sequence", "collection_id"], name: "UNIQ_F2718C965286D72B514956FD", unique: true, using: :btree
  add_index "sub_rating_question", ["type_id"], name: "IDX_F2718C96C54C8C93", using: :btree

  create_table "sub_rating_question_order", force: :cascade do |t|
    t.string "name", limit: 255, null: false
  end

  create_table "sub_rating_question_type", force: :cascade do |t|
    t.string "name", limit: 255, null: false
  end

  create_table "user", force: :cascade do |t|
    t.integer "image_id",      limit: 4
    t.string  "username",      limit: 255, null: false
    t.string  "salt",          limit: 32,  null: false
    t.string  "password",      limit: 40,  null: false
    t.boolean "is_active",                 null: false
    t.string  "first_name",    limit: 255
    t.string  "last_name",     limit: 255
    t.string  "email_address", limit: 255
  end

  add_index "user", ["email_address"], name: "UNIQ_8D93D649B08E074E", unique: true, using: :btree
  add_index "user", ["image_id"], name: "UNIQ_8D93D6493DA5256D", unique: true, using: :btree
  add_index "user", ["username"], name: "UNIQ_8D93D649F85E0677", unique: true, using: :btree

  create_table "user_group", id: false, force: :cascade do |t|
    t.integer "user_id",  limit: 4, null: false
    t.integer "group_id", limit: 4, null: false
  end

  add_index "user_group", ["group_id"], name: "IDX_8F02BF9DFE54D947", using: :btree
  add_index "user_group", ["user_id"], name: "IDX_8F02BF9DA76ED395", using: :btree

  create_table "verified_client", force: :cascade do |t|
    t.integer "company_id",    limit: 4
    t.integer "user_id",       limit: 4
    t.string  "client_id",     limit: 255, null: false
    t.string  "first_name",    limit: 255
    t.string  "last_name",     limit: 255, null: false
    t.string  "email_address", limit: 255, null: false
  end

  add_index "verified_client", ["client_id", "company_id"], name: "UNIQ_E085566819EB6921979B1AD6", unique: true, using: :btree
  add_index "verified_client", ["company_id"], name: "IDX_E0855668979B1AD6", using: :btree
  add_index "verified_client", ["email_address"], name: "UNIQ_E0855668B08E074E", unique: true, using: :btree
  add_index "verified_client", ["user_id"], name: "IDX_E0855668A76ED395", using: :btree

  add_foreign_key "contact", "rateable", name: "FK_4C62E638676F61C9"
  add_foreign_key "contact", "rating", name: "FK_4C62E638A32EFC6"
  add_foreign_key "contact", "verified_client", column: "client_id", name: "FK_4C62E63819EB6921"
  add_foreign_key "quiz", "rateable", name: "FK_A412FA92676F61C9", on_delete: :cascade
  add_foreign_key "quiz_question", "rateable_collection", name: "FK_6033B00B2ABDBC3E", on_delete: :cascade
  add_foreign_key "quiz_reply", "quiz", name: "FK_1DBBF60853CD175", on_delete: :cascade
  add_foreign_key "quiz_reply", "quiz_question", column: "question_id", name: "FK_1DBBF601E27F6BF", on_delete: :cascade
  add_foreign_key "quiz_reply", "quiz_wrong_answer", column: "wrong_given_answer_id", name: "FK_1DBBF6091C0F811", on_delete: :cascade
  add_foreign_key "quiz_wrong_answer", "quiz_question", column: "question_id", name: "FK_8B511E6C1E27F6BF", on_delete: :cascade
  add_foreign_key "rateable", "identifier", name: "FK_5BAE876BEF794DF6"
  add_foreign_key "rateable", "image", name: "FK_5BAE876B3DA5256D"
  add_foreign_key "rateable", "rateable_collection", column: "collection_id", name: "FK_5BAE876B514956FD"
  add_foreign_key "rateable", "user", column: "rateable_user_id", name: "FK_5BAE876B7FC3D43D"
  add_foreign_key "rateable_collection", "company", name: "FK_CC0020A0979B1AD6"
  add_foreign_key "rateable_collection", "identifier", name: "FK_CC0020A0EF794DF6"
  add_foreign_key "rateable_collection", "image", name: "FK_CC0020A03DA5256D"
  add_foreign_key "rateable_collection", "sub_rating_question_order", column: "question_order_id", name: "FK_CC0020A0EE97DD34"
  add_foreign_key "rateable_collection_owner", "rateable_collection", column: "collection_id", name: "FK_5305B2E514956FD"
  add_foreign_key "rateable_collection_owner", "user", name: "FK_5305B2EA76ED395"
  add_foreign_key "rating", "rateable", name: "FK_D8892622676F61C9"
  add_foreign_key "rating", "user", column: "rating_user_id", name: "FK_D889262244222AED"
  add_foreign_key "sub_rating", "rating", name: "FK_6AD8696EA32EFC6"
  add_foreign_key "sub_rating", "sub_rating_answer", column: "answer_id", name: "FK_6AD8696EAA334807"
  add_foreign_key "sub_rating_answer", "sub_rating_answer_type", column: "type_id", name: "FK_3A82E773C54C8C93"
  add_foreign_key "sub_rating_answer", "sub_rating_question", column: "question_id", name: "FK_3A82E7731E27F6BF"
  add_foreign_key "sub_rating_answer_type", "sub_rating_question_type", column: "question_type_id", name: "FK_E339D53BCB90598E"
  add_foreign_key "sub_rating_question", "rateable_collection", column: "collection_id", name: "FK_F2718C96514956FD"
  add_foreign_key "sub_rating_question", "sub_rating_question_type", column: "type_id", name: "FK_F2718C96C54C8C93"
  add_foreign_key "user", "image", name: "FK_8D93D6493DA5256D"
  add_foreign_key "user_group", "role", column: "group_id", name: "FK_8F02BF9DFE54D947"
  add_foreign_key "user_group", "user", name: "FK_8F02BF9DA76ED395"
  add_foreign_key "verified_client", "company", name: "FK_E0855668979B1AD6"
  add_foreign_key "verified_client", "user", name: "FK_E0855668A76ED395"
end
