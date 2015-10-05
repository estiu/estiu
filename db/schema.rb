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

ActiveRecord::Schema.define(version: 20151004201634) do

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
    t.string   "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "campaigns", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "goal_cents"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "event_promoter_id", null: false
  end

  add_index "campaigns", ["event_promoter_id"], name: "index_campaigns_on_event_promoter_id", using: :btree

  create_table "contacts", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "phone"
    t.string   "email"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.integer  "contactable_id"
    t.string   "contactable_type"
  end

  add_index "contacts", ["contactable_type", "contactable_id"], name: "index_contacts_on_contactable_type_and_contactable_id", using: :btree

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
    t.integer  "attendee_id",  null: false
    t.integer  "campaign_id",  null: false
    t.integer  "amount_cents"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "pledges", ["attendee_id"], name: "index_pledges_on_attendee_id", using: :btree
  add_index "pledges", ["campaign_id"], name: "index_pledges_on_campaign_id", using: :btree

  create_table "tickets", force: :cascade do |t|
    t.integer  "attendee_id", null: false
    t.integer  "event_id",    null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "tickets", ["attendee_id"], name: "index_tickets_on_attendee_id", using: :btree
  add_index "tickets", ["event_id"], name: "index_tickets_on_event_id", using: :btree

  create_table "venues", force: :cascade do |t|
    t.string   "name"
    t.string   "address"
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_foreign_key "artist_catalog_entries", "artist_promoters"
  add_foreign_key "artist_catalog_entries", "artists"
  add_foreign_key "artists_events", "artists"
  add_foreign_key "artists_events", "events"
  add_foreign_key "campaigns", "event_promoters"
  add_foreign_key "events", "campaigns"
  add_foreign_key "events", "venues"
  add_foreign_key "pledges", "attendees"
  add_foreign_key "pledges", "campaigns"
  add_foreign_key "tickets", "attendees"
  add_foreign_key "tickets", "events"
end