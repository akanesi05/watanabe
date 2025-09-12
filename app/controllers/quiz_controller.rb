class QuizController < ApplicationController
  def index
    # トップページ
  end
  
  def start
  # 食べ物をランダムに5つ選択（total_questionsに合わせて調整）
      foods = Food.order("RANDOM()").limit(5)  # PostgreSQLの場合
  # foods = Food.all.sample(5)  # SQLiteの場合はこちら
  
  # クイズ開始時の処理
      session[:quiz] = {
      food_ids: foods.pluck(:id),  # ←これが重要！クイズで使う食べ物のIDリスト
      score: 0,
    current_question: 1,
    total_questions: 5           # 5問に修正（food_idsの数と合わせる）
  }
  
  redirect_to quiz_question_path
  end

def question
  puts "=== QUESTION ACTION DEBUG START ==="
  puts "session全体: #{session.inspect}"
  puts "session[:quiz]: #{session[:quiz].inspect}"
  
  # セッション確認
  unless session[:quiz]
    puts "ERROR: session[:quiz]がnil！"
    redirect_to quiz_start_path, alert: "クイズを開始してください"
    return
  end
  
  quiz_data = session[:quiz]
  puts "quiz_data: #{quiz_data.inspect}"
  
  # 現在の問題番号確認（文字列キーでアクセス）
  current_question_num = quiz_data['current_question'] || 1
  puts "current_question_num: #{current_question_num}"
  
  # food_ids配列確認（文字列キーでアクセス）
  food_ids = quiz_data['food_ids']  # ←ここを文字列キーに変更
  
  puts "food_ids: #{food_ids.inspect}"
  puts "food_ids.class: #{food_ids.class}"
  
  if food_ids.nil? || food_ids.empty?
    puts "ERROR: food_idsが存在しない！"
    redirect_to quiz_start_path, alert: "クイズデータが不正です"
    return
  end
  
  # 現在の食べ物ID取得
  current_food_id = food_ids[current_question_num - 1]
  
  @food = @current_food 
  puts "current_food_id: #{current_food_id}"
  
  if current_food_id.nil?
    puts "ERROR: current_food_idがnil！"
    redirect_to quiz_start_path, alert: "問題データが見つかりません"
    return
  end
  
  # 食べ物データ取得
  @current_food = Food.find_by(id: current_food_id)
  puts "@current_food: #{@current_food.inspect}"
  
  if @current_food.nil?
    puts "ERROR: @current_foodがnil！"
    redirect_to quiz_start_path, alert: "食べ物データが見つかりません"
    return
  end
  
  puts "=== QUESTION ACTION DEBUG END ==="
end
  

def answer
  puts "=== ANSWER DEBUG START ==="
  puts "session全体: #{session.inspect}"
  puts "session[:quiz]: #{session[:quiz].inspect}"
  puts "params: #{params.inspect}"
  
  # セッション確認
  unless session[:quiz]
    redirect_to quiz_start_path, alert: "クイズを開始してください"
    return
  end
  
  quiz_data = session[:quiz]
  
  # 現在の問題の食べ物を取得（文字列キーでアクセス）
  current_food_id = quiz_data['food_ids'][quiz_data['current_question'] - 1]
  puts "current_food_id: #{current_food_id}"
  
  current_food = Food.find(current_food_id)
  puts "current_food: #{current_food.inspect}"
  puts "current_food.category: #{current_food.category}"
  
  # ユーザーの回答を取得
  user_answer = params[:answer]  # "safe" or "dangerous"
  puts "user_answer: #{user_answer}"
  
  # 正解判定（categoryカラムを使用）
  correct_answer = (current_food.category == "ok") ? "safe" : "dangerous"
  puts "correct_answer: #{correct_answer}"
  
  is_correct = (user_answer == correct_answer)
  puts "is_correct: #{is_correct}"
  
  # スコア更新（文字列キーでアクセス）
  if is_correct
    quiz_data['score'] += 1
  end
  
  # 次の問題に進む（文字列キーでアクセス）
  quiz_data['current_question'] += 1
  
  # セッション更新
  session[:quiz] = quiz_data
  
  puts "更新後のセッション: #{session[:quiz].inspect}"
  puts "=== ANSWER DEBUG END ==="
  
  # 全問題が終了したかチェック（文字列キーでアクセス）
  if quiz_data['current_question'] > quiz_data['total_questions']
    redirect_to quiz_result_path
  else
    redirect_to quiz_question_path
  end
end

def result
  puts "=== RESULT DEBUG START ==="
  puts "session全体: #{session.inspect}"
  puts "session[:quiz]: #{session[:quiz].inspect}"
  
  # セッション確認
  unless session[:quiz]
    redirect_to quiz_start_path, alert: "クイズを開始してください"
    return
  end
  
  quiz_data = session[:quiz]
  puts "quiz_data: #{quiz_data.inspect}"
  
  # 結果データを準備（文字列キーでアクセス）
  @score = quiz_data['score']
  @total_questions = quiz_data['total_questions']
  @percentage = (@score.to_f / @total_questions * 100).round(1)
  
  puts "スコア: #{@score}/#{@total_questions} (#{@percentage}%)"
  
  # 結果メッセージの設定
  @result_message = case @percentage
                   when 80..100
                     "素晴らしい！渡辺さんの食生活をよく理解していますね！"
                   when 60...80
                     "なかなか良い成績です！もう少し勉強してみましょう。"
                   when 40...60
                     "まずまずですね。渡辺さんのことをもっと知る必要がありそうです。"
                   else
                     "渡辺さんのことをもっと勉強しましょう！"
                   end
      @evaluation = case @percentage
                when 80..100
                  {
                    emoji: "🎉",
                    title: "完璧！",
                    comment: "渡辺さんマスターですね！素晴らしい成績です！"
                  }
                when 60...80
                  {
                    emoji: "😊",
                    title: "良い成績！",
                    comment: "なかなか良い理解度です。もう少し頑張りましょう！"
                  }
                when 40...60
                  {
                    emoji: "🤔",
                    title: "まずまず",
                    comment: "渡辺さんのことをもっと知る必要がありそうです。"
                  }
                else
                  {
                    emoji: "😅",
                    title: "要勉強",
                    comment: "渡辺さんのことをもっと勉強しましょう！次回は頑張って！"
                  }
                end
  
  puts "結果メッセージ: #{@result_message}"
  puts "=== RESULT DEBUG END ==="
  
  # クイズ終了後、セッションをクリア
  session.delete(:quiz)
end
end
