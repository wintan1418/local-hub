# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_09_02_182532) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "availabilities", force: :cascade do |t|
    t.bigint "service_id", null: false
    t.integer "day_of_week"
    t.time "start_time"
    t.time "end_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["service_id"], name: "index_availabilities_on_service_id"
  end

  create_table "bookings", force: :cascade do |t|
    t.bigint "customer_id", null: false
    t.bigint "service_id", null: false
    t.datetime "scheduled_at"
    t.integer "status"
    t.decimal "total_price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_bookings_on_customer_id"
    t.index ["service_id"], name: "index_bookings_on_service_id"
  end

  create_table "campaign_recipients", force: :cascade do |t|
    t.bigint "crm_campaign_id", null: false
    t.bigint "user_id", null: false
    t.string "status"
    t.datetime "sent_at"
    t.datetime "delivered_at"
    t.string "error_message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["crm_campaign_id"], name: "index_campaign_recipients_on_crm_campaign_id"
    t.index ["user_id"], name: "index_campaign_recipients_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.string "icon"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "chat_messages", force: :cascade do |t|
    t.bigint "conversation_id", null: false
    t.bigint "sender_id", null: false
    t.text "content"
    t.datetime "read_at"
    t.integer "message_type", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "reply_to_id"
    t.boolean "pinned", default: false
    t.datetime "deleted_at", precision: nil
    t.datetime "edited_at", precision: nil
    t.index ["conversation_id", "created_at"], name: "index_chat_messages_on_conversation_id_and_created_at"
    t.index ["conversation_id"], name: "index_chat_messages_on_conversation_id"
    t.index ["created_at"], name: "index_chat_messages_on_created_at"
    t.index ["deleted_at"], name: "index_chat_messages_on_deleted_at"
    t.index ["pinned"], name: "index_chat_messages_on_pinned"
    t.index ["reply_to_id"], name: "index_chat_messages_on_reply_to_id"
    t.index ["sender_id"], name: "index_chat_messages_on_sender_id"
  end

  create_table "conversations", force: :cascade do |t|
    t.bigint "customer_id", null: false
    t.bigint "provider_id", null: false
    t.integer "status", default: 0
    t.datetime "last_message_at"
    t.integer "unread_count_customer", default: 0
    t.integer "unread_count_provider", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id", "provider_id"], name: "index_conversations_on_customer_id_and_provider_id", unique: true
    t.index ["customer_id"], name: "index_conversations_on_customer_id"
    t.index ["last_message_at"], name: "index_conversations_on_last_message_at"
    t.index ["provider_id"], name: "index_conversations_on_provider_id"
  end

  create_table "crm_campaigns", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "campaign_type"
    t.string "status"
    t.string "target_audience"
    t.text "message_template"
    t.datetime "scheduled_at"
    t.integer "sent_count"
    t.integer "success_count"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_crm_campaigns_on_user_id"
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "sender_id", null: false
    t.bigint "recipient_id", null: false
    t.bigint "booking_id", null: false
    t.text "content"
    t.boolean "read"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["booking_id"], name: "index_messages_on_booking_id"
    t.index ["recipient_id"], name: "index_messages_on_recipient_id"
    t.index ["sender_id"], name: "index_messages_on_sender_id"
  end

  create_table "notification_preferences", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.boolean "sms_enabled"
    t.boolean "whatsapp_enabled"
    t.boolean "email_enabled"
    t.boolean "booking_reminders"
    t.boolean "marketing_messages"
    t.boolean "service_updates"
    t.time "quiet_hours_start"
    t.time "quiet_hours_end"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_notification_preferences_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "notifiable_type"
    t.bigint "notifiable_id"
    t.string "notification_type", null: false
    t.string "title", null: false
    t.text "message", null: false
    t.datetime "read_at"
    t.json "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["notifiable_type", "notifiable_id"], name: "index_notifications_on_notifiable"
    t.index ["notification_type"], name: "index_notifications_on_notification_type"
    t.index ["user_id", "created_at"], name: "index_notifications_on_user_id_and_created_at"
    t.index ["user_id", "read_at"], name: "index_notifications_on_user_id_and_read_at"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "phone_verifications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "phone"
    t.string "code"
    t.boolean "verified"
    t.datetime "verified_at"
    t.datetime "expires_at"
    t.integer "attempts"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_phone_verifications_on_user_id"
  end

  create_table "plans", force: :cascade do |t|
    t.string "name", null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.string "stripe_price_id"
    t.json "features"
    t.boolean "active", default: true
    t.integer "billing_period", default: 0
    t.integer "position", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_plans_on_active"
    t.index ["stripe_price_id"], name: "index_plans_on_stripe_price_id", unique: true
  end

  create_table "reviews", force: :cascade do |t|
    t.bigint "booking_id", null: false
    t.integer "rating"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["booking_id"], name: "index_reviews_on_booking_id"
  end

  create_table "service_areas", force: :cascade do |t|
    t.bigint "service_id", null: false
    t.string "city"
    t.string "state"
    t.string "zip"
    t.integer "radius"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["service_id"], name: "index_service_areas_on_service_id"
  end

  create_table "services", force: :cascade do |t|
    t.bigint "provider_id", null: false
    t.bigint "category_id", null: false
    t.string "title"
    t.text "description"
    t.integer "price_type"
    t.decimal "base_price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_services_on_category_id"
    t.index ["provider_id"], name: "index_services_on_provider_id"
  end

  create_table "sms_logs", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "phone_number"
    t.string "message_type"
    t.text "content"
    t.string "status"
    t.string "twilio_sid"
    t.string "error_message"
    t.datetime "sent_at"
    t.datetime "delivered_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sms_logs_on_user_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "status"
    t.integer "plan_type"
    t.string "stripe_subscription_id"
    t.string "stripe_customer_id"
    t.datetime "current_period_start"
    t.datetime "current_period_end"
    t.boolean "cancel_at_period_end", default: false
    t.bigint "plan_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["plan_id"], name: "index_subscriptions_on_plan_id"
    t.index ["stripe_customer_id"], name: "index_subscriptions_on_stripe_customer_id"
    t.index ["stripe_subscription_id"], name: "index_subscriptions_on_stripe_subscription_id", unique: true
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_role"
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.text "bio"
    t.string "address"
    t.string "city"
    t.string "state"
    t.string "zip_code"
    t.string "business_name"
    t.string "business_license"
    t.string "insurance_number"
    t.integer "years_experience", default: 0
    t.boolean "verified", default: false
    t.datetime "verified_at"
    t.string "stripe_customer_id"
    t.boolean "business_license_document", default: false
    t.boolean "insurance_certificate_document", default: false
    t.boolean "professional_certifications_document", default: false
    t.boolean "government_id_document", default: false
    t.string "admin_role"
    t.datetime "confirmed_at"
    t.string "confirmation_token"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.index ["admin_role"], name: "index_users_on_admin_role"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["stripe_customer_id"], name: "index_users_on_stripe_customer_id", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "availabilities", "services"
  add_foreign_key "bookings", "services"
  add_foreign_key "bookings", "users", column: "customer_id"
  add_foreign_key "campaign_recipients", "crm_campaigns"
  add_foreign_key "campaign_recipients", "users"
  add_foreign_key "chat_messages", "chat_messages", column: "reply_to_id"
  add_foreign_key "chat_messages", "conversations"
  add_foreign_key "chat_messages", "users", column: "sender_id"
  add_foreign_key "conversations", "users", column: "customer_id"
  add_foreign_key "conversations", "users", column: "provider_id"
  add_foreign_key "crm_campaigns", "users"
  add_foreign_key "messages", "bookings"
  add_foreign_key "messages", "users", column: "recipient_id"
  add_foreign_key "messages", "users", column: "sender_id"
  add_foreign_key "notification_preferences", "users"
  add_foreign_key "notifications", "users"
  add_foreign_key "phone_verifications", "users"
  add_foreign_key "reviews", "bookings"
  add_foreign_key "service_areas", "services"
  add_foreign_key "services", "categories"
  add_foreign_key "services", "users", column: "provider_id"
  add_foreign_key "sms_logs", "users"
  add_foreign_key "subscriptions", "plans"
  add_foreign_key "subscriptions", "users"
end
