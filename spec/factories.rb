FactoryBot.define do
  sequence(:email) { |n| "user_#{n}@example.com" }

  sequence(:url) { |n| "http://example.com/url_#{n}" }

  factory :reindex_run do
  end

  factory :topic do
    sequence(:name) { |n| "Topic Name #{n}" }

    trait :with_children do
      after(:create) do |instance|
        create(:topic, parent: instance)
        create(:topic, parent: instance)
      end
    end
  end

  factory :notice_topic, class: 'Topic' do
    sequence(:name) { |n| Lumen::TOPICS[n % Lumen::TOPICS.size - 1] }
  end

  factory :topic_manager do
    name { 'A name' }
  end

  factory :dmca do
    sequence(:id) { |n| n }
    title { 'A title' }
    date_received { Time.now }
    date_sent { Time.now }

    works { build_list(:work, 1) }

    transient do
      role_names { ['recipient'] }
    end

    after :build do |notice, evaluator|
      evaluator.role_names.each do |role_name|
        role = notice.entity_notice_roles.build(name: role_name)
        role.entity = build(:entity)
      end
    end

    trait :with_body do
      body { 'A body' }
    end

    trait :with_tags do
      before(:create) do |notice|
        notice.tag_list = 'a_tag, another_tag'
      end
    end

    trait :with_jurisdictions do
      before(:create) do |notice|
        notice.jurisdiction_list = 'us, ca'
      end
    end

    trait :with_topics do
      before(:create) do |notice|
        notice.topics << build_list(:topic, 3)
      end
    end

    trait :with_infringing_urls do # through works
      before(:create) do |notice|
        notice.works.first.infringing_urls = build_list(:infringing_url, 3)
      end
    end

    trait :with_copyrighted_urls do # through works
      before(:create) do |notice|
        notice.works.first.copyrighted_urls = build_list(:copyrighted_url, 3)
      end
    end

    trait :with_facet_data do
      language { 'en' }
      action_taken { 'Yes' }
      with_tags
      with_jurisdictions
      with_topics
      role_names { %w[sender principal recipient] }
      date_received { Time.now }
    end

    trait :redactable do
      body { "Some #{Lumen::REDACTION_MASK} body" }
      body_original { 'Some sensitive body' }
      review_required { true }
    end

    trait :with_original do
      before(:create) do |notice|
        notice.file_uploads << build(:file_upload, kind: 'original')
      end
    end

    trait :with_document do
      before(:create) do |notice|
        notice.file_uploads << build(:file_upload, kind: 'supporting')
      end
    end

    trait :with_pdf do
      before(:create) do |notice|
        notice.file_uploads << build(
          :file_upload, kind: 'supporting', file_content_type: 'application/pdf'
        )
      end
    end

    trait :with_image do
      before(:create) do |notice|
        notice.file_uploads << build(
          :file_upload, kind: 'supporting', file_content_type: 'image/jpeg'
        )
      end
    end

    factory :counterfeit, class: 'Counterfeit'
    factory :counternotice, class: 'Counternotice'
    factory :court_order, class: 'CourtOrder'
    factory :data_protection, class: 'DataProtection'
    factory :defamation, class: 'Defamation'
    factory :government_request, class: 'GovernmentRequest'
    factory :law_enforcement_request, class: 'LawEnforcementRequest'
    factory :other, class: 'Other'
    factory :private_information, class: 'PrivateInformation'
    factory :trademark, class: 'Trademark'
    factory :placeholder, class: 'Placeholder'
  end

  factory :file_upload do
    transient do
      content { 'Content' }
    end

    kind { 'original' }

    file do
      Tempfile.open('factory_file') do |fh|
        fh.write(content)
        fh.flush

        Rack::Test::UploadedFile.new(fh.path, 'text/plain')
      end
    end
  end

  factory :entity_notice_role do
    entity
    association(:notice, factory: :dmca)
    name { 'principal' }
  end

  factory :entity do
    sequence(:name) { |n| "Entity name #{n}" }
    kind { 'individual' }
    address_line_1 { 'Address 1' }
    address_line_2 { 'Address 2' }
    city { 'City' }
    state { 'State' }
    zip { '01222' }
    country_code { 'US' }
    phone { '555-555-1212' }
    email { 'foo@example.com' }
    url { 'http://www.example.com' }

    trait :with_children do
      after(:create) do |instance|
        create(:entity, parent: instance)
        create(:entity, parent: instance)
      end
    end
    trait :with_parent do
      before(:create) do |instance|
        instance.parent = create(:entity)
      end
    end
  end

  factory :user do
    email
    password { 'secretsauce' }
    password_confirmation { 'secretsauce' }

    trait :notice_viewer do
      roles { [Role.notice_viewer] }
    end

    trait :submitter do
      roles { [Role.submitter] }
    end

    trait :redactor do
      roles { [Role.redactor] }
    end

    trait :publisher do
      roles { [Role.publisher] }
    end

    trait :admin do
      roles { [Role.admin] }
    end

    trait :super_admin do
      roles { [Role.super_admin] }
    end

    trait :with_entity do
      entity
    end

    trait :researcher do
      roles { [Role.researcher] }
    end

    trait :researcher_truncated_urls do
      roles { [Role.researcher_truncated_urls] }
    end
  end

  factory :relevant_question do
    question { 'What is the meaning of life?' }
    answer { '42' }
  end

  factory :work do
    description { 'Something copyrighted' }

    trait :with_infringing_urls do
      after(:build) do |work|
        work.infringing_urls = build_list(:infringing_url, 3)
      end
    end

    trait :with_copyrighted_urls do
      after(:build) do |work|
        work.copyrighted_urls = build_list(:copyrighted_url, 3)
      end
    end
  end

  factory :infringing_url do
    url
    url_original { url }
  end

  factory :copyrighted_url do
    url
    url_original { url }
  end

  factory :role do
    name { 'test_role' }
  end

  factory :token_url do
    email { 'user@example.com' }
    notice { build(:dmca) }
  end
end
