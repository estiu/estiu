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

ActiveRecord::Schema.define(version: 20151104104612) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "artist_catalog_entries", force: :cascade do |t|
    t.integer  "artist_id",          null: false
    t.integer  "artist_promoter_id", null: false
    t.integer  "price_cents"
    t.integer  "act_duration"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "artist_catalog_entries", ["artist_id"], name: "index_artist_catalog_entries_on_artist_id", using: :btree
  add_index "artist_catalog_entries", ["artist_promoter_id"], name: "index_artist_catalog_entries_on_artist_promoter_id", using: :btree

  create_table "artist_promoters", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.string   "website"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "artists", force: :cascade do |t|
    t.string   "name"
    t.string   "telephone"
    t.string   "email"
    t.string   "website"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "artists_events", force: :cascade do |t|
    t.integer  "artist_id",  null: false
    t.integer  "event_id",   null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "artists_events", ["artist_id"], name: "index_artists_events_on_artist_id", using: :btree
  add_index "artists_events", ["event_id"], name: "index_artists_events_on_event_id", using: :btree

  create_table "attendees", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "campaigns", force: :cascade do |t|
    t.string   "name"
    t.string   "unfulfillment_check_id"
    t.text     "description"
    t.integer  "goal_cents"
    t.integer  "minimum_pledge_cents"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.datetime "fulfilled_at"
    t.datetime "unfulfilled_at"
    t.boolean  "skip_past_date_validations"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "event_promoter_id",          null: false
    t.integer  "venue_id",                   null: false
  end

  add_index "campaigns", ["event_promoter_id"], name: "index_campaigns_on_event_promoter_id", using: :btree
  add_index "campaigns", ["venue_id"], name: "index_campaigns_on_venue_id", using: :btree

  create_table "contacts", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "phone"
    t.string   "email"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.integer  "contactable_id",   null: false
    t.string   "contactable_type", null: false
  end

  add_index "contacts", ["contactable_type", "contactable_id"], name: "index_contacts_on_contactable_type_and_contactable_id", using: :btree

  create_table "credits", force: :cascade do |t|
    t.integer  "attendee_id"
    t.integer  "pledge_id"
    t.integer  "amount_cents", null: false
    t.boolean  "charged",      null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "credits", ["attendee_id"], name: "index_credits_on_attendee_id", using: :btree
  add_index "credits", ["pledge_id"], name: "index_credits_on_pledge_id", using: :btree

  create_table "event_promoters", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.string   "website"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "events", force: :cascade do |t|
    t.string   "name"
    t.datetime "starts_at"
    t.integer  "duration"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "campaign_id", null: false
    t.integer  "venue_id",    null: false
  end

  add_index "events", ["campaign_id"], name: "index_events_on_campaign_id", using: :btree
  add_index "events", ["venue_id"], name: "index_events_on_venue_id", using: :btree

  create_table "pledges", force: :cascade do |t|
    t.integer  "attendee_id",                           null: false
    t.integer  "campaign_id",                           null: false
    t.integer  "amount_cents",                          null: false
    t.integer  "discount_cents",           default: 0
    t.integer  "originally_pledged_cents",              null: false
    t.string   "stripe_charge_id"
    t.string   "referral_email"
    t.integer  "desired_credit_ids",       default: [], null: false, array: true
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  add_index "pledges", ["attendee_id"], name: "index_pledges_on_attendee_id", using: :btree
  add_index "pledges", ["campaign_id"], name: "index_pledges_on_campaign_id", using: :btree

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "tickets", force: :cascade do |t|
    t.integer  "attendee_id", null: false
    t.integer  "event_id",    null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "tickets", ["attendee_id"], name: "index_tickets_on_attendee_id", using: :btree
  add_index "tickets", ["event_id"], name: "index_tickets_on_event_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                         default: "", null: false
    t.string   "encrypted_password",            default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                 default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.string   "roles",                         default: [],              array: true
    t.integer  "artist_id"
    t.integer  "artist_promoter_id"
    t.integer  "event_promoter_id"
    t.integer  "attendee_id"
    t.string   "facebook_user_id"
    t.boolean  "signed_up_via_facebook"
    t.string   "facebook_access_token"
    t.datetime "facebook_access_token_expires"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "venues", force: :cascade do |t|
    t.string   "name"
    t.string   "address"
    t.text     "description"
    t.integer  "capacity"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_foreign_key "artist_catalog_entries", "artist_promoters"
  add_foreign_key "artist_catalog_entries", "artists"
  add_foreign_key "artists_events", "artists"
  add_foreign_key "artists_events", "events"
  add_foreign_key "campaigns", "event_promoters"
  add_foreign_key "campaigns", "venues"
  add_foreign_key "credits", "attendees"
  add_foreign_key "credits", "pledges"
  add_foreign_key "events", "campaigns"
  add_foreign_key "events", "venues"
  add_foreign_key "pledges", "attendees"
  add_foreign_key "pledges", "campaigns"
  add_foreign_key "tickets", "attendees"
  add_foreign_key "tickets", "events"
  add_foreign_key "users", "artist_promoters"
  add_foreign_key "users", "artists"
  add_foreign_key "users", "attendees"
  add_foreign_key "users", "event_promoters"
end
