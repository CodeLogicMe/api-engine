ActiveRecord::Base.transaction do
  if Models::Tier.count > 0
    exit
  end

  Models::Tier.create! name: 'Alpha',     quota: 1_000_000, price: 0
  Models::Tier.create! name: 'Free',      quota: 1_500,     price: 0
  Models::Tier.create! name: 'Prototype', quota: 5_000,     price: 20
  Models::Tier.create! name: 'Small',     quota: 50_000,    price: 60
  Models::Tier.create! name: 'Medium',    quota: 200_000,   price: 150
  Models::Tier.create! name: 'Large',     quota: 1_000_000, price: 300

  Models::Client.create! email: 'lukas@codelogic.me', password: 'lukastm'
end
