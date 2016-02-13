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
    csv_file_path = csv_filenames.map { |cf| "#{home_dir}/manhattan_csv/#{cf}" }
    result = `democheckword #{csv_file_path.join(' ')}`
    word = result.match(/^[^\s]+/)[0]
    logger.info("word : #{word}")

    if result =~ /\A0/ || word == 'error'
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
        [21, 51], [27, 50], [37, 48], [42, 47], [52, 45], [63, 43], [70, 41], [80, 37], [89, 33], [95, 30], [102, 28], [106, 27], [111, 25], [114, 27], [107, 32], [96, 40], [86, 51], [77, 57], [71, 64], [66, 71], [62, 78], [59, 85], [57, 91], [56, 95], [56, 100], [56, 105], [61, 108], [69, 112], [78, 114], [94, 117], [109, 119], [122, 121], [133, 122], [139, 123]
      ],
      [
        [24, 77], [30, 73], [39, 70], [55, 63], [70, 59], [77, 58], [89, 57], [98, 57], [103, 57], [109, 59], [111, 63], [112, 67], [112, 72], [112, 78], [107, 88], [101, 97], [97, 102], [94, 108], [92, 112]
      ],
      [
        [40,98], [42,89], [45,84], [50,78], [54,75], [61,69], [66,67], [71,65], [77,62], [82,61], [87,59], [93,58], [101,58], [104,61], [108,67], [109,73], [109,83], [106,87], [102,90], [98,93], [90,90], [88,81], [86,71], [85,62], [83,54], [83,47], [84,62], [84,75], [84,84], [84,93], [84,99], [78,96], [74,89], [70,83], [68,79], [65,74], [63,70], [63,65], [61,61], [61,69], [61,80], [61,94], [63,106], [66,114], [70,122], [72,126], [75,130]
      ]
    ]
  end

  def make_csv_filenames
    ['1.csv', '2.csv', '3.csv'].map { |f| "#{Time.now.strftime('%Y%m%d%H%M%S')}_#{f}" }
  end
end
