require 'csv'

class ShiritorisController < ApplicationController
  WORD_SIZE = 3

  def analysis
    # TODO: csvファイルを作る
    csv_filenames = make_csv_filenames
    logger.info("csv_filenames : #{csv_filenames}")
    data = make_array

    # csvファイルを保存する
    home_dir = `echo $HOME`.chomp
    logger.info("home_dir : #{home_dir}")

    data.each_with_index do |csv_data, index|
      CSV.open("#{home_dir}/manhattan_csv/#{csv_filenames[index]}", 'w') do |csv_file|
        csv_data.each do |row|
          csv_file << row
        end
      end
    end

    # Zinnia, Mecubで調べる
    result = `checkword #{csv_filenames.join(' ')}`
    word = result.match(/^[^\s]+/)[0]
    logger.info("word : #{word}")

    if result =~ /\A0/
      logger.info("0 : 認識不可!")
      res_json = { status: 0, message: "認識不可！" }
    elsif word.size < WORD_SIZE
      logger.info("1 : 単語無し！")
      res_json = { status: 1, message: "単語無し！", word: word }
    else
      # TODO: しりとりチェック
      logger.info("3 : ok!")
      res_json = { status: 3, message: "ok!", word: word }
    end
    render json: res_json
  end

  private

  def make_array
    [
      [
        [266,120], [283,756], [610,873], [760,693]
      ],
      [
        [266,120], [283,756], [610,873], [760,693]
      ],
      [
        [266,120], [283,756], [610,873], [760,693]
      ]
    ]
  end

  def make_csv_filenames
    ['1.csv', '2.csv', '3.csv'].map { |f| "#{Time.now.strftime('%Y%m%d%H%M%S')}_#{f}" }
  end
end
