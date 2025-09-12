# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

foods_data = [
  { name: "マヨネーズ", category: "ok", description: "卵の原型をとどめていない" },
  { name: "マックのハンバーガー", category: "ng", description: "肉の原型がない" },
  { name: "唐揚げ", category: "ng", description: "鳥だから" },
  { name: "鶏肉", category: "ng", description: "鳥なので" },
  { name: "ケンタッキー", category: "ng", description: "鳥類２階に行くほど無理" },
  { name: "バーガーキングのパティ", category: "ng", description: "肉肉しい" },
   { name: "大豆ミート", category: "ok", description: "肉じゃない" },
   { name: "チャーシュー", category: "ng", description: "ハムだと言われて食べたら騙された" },
   { name: "ハム", category: "ok", description: "肉っぽくない" },
   { name: "会社のカレー", category: "ok", description: "溶けてるから" },
  # ... 10問以上のデータを用意
]

foods_data.each do |food_data|
  Food.create!(food_data)
end
