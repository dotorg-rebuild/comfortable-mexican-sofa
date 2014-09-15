FactoryGirl.define do
  factory :project do
    title { Faker::Movie.title }

    factory :project_with_producers do
      after :create do |project, evaluator|
        create_list(:credit, 2, project: project)
      end
    end
  end
end
