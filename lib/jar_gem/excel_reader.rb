require 'uri'

java_import java.net.URL
java_import java.io.FileInputStream
java_import org.apache.commons.compress.archivers.zip.ZipFile
java_import org.apache.poi.ss.usermodel.Cell
java_import org.apache.poi.ss.usermodel.DateUtil
java_import org.apache.poi.ss.usermodel.Row
java_import org.apache.poi.ss.usermodel.Sheet
java_import org.apache.poi.ss.usermodel.Workbook
java_import org.apache.poi.ss.usermodel.WorkbookFactory
java_import org.apache.poi.xssf.usermodel.XSSFWorkbook
java_import org.apache.poi.xssf.usermodel.XSSFSheet
java_import org.apache.poi.hssf.usermodel.HSSFWorkbook
java_import org.apache.poi.hssf.usermodel.HSSFSheet

class ExcelReader
  # インスタンスの初期化
  #
  # @param [Hash, JSON] config 設定
  def initialize(config)
    @config = config
    raise "無効な設定が与えられました" unless valid_config?
  end

  # Excelの読み込み
  #
  # @param [String] resource 入力リソース
  # @yield [input]
  # @yieldparam [Input] input 入力データクラス
  def read(resource)
    open(resource)
    return unless @workbook.present?
    @workbook.each_with_index do |sheet, sheet_index|
      sheet_name = sheet.getSheetName
      row_lengths = sheet.getLastRowNum.to_i
      sheet_config = @config[sheet_index]
      raise BatchRegistration::ApplicationError, "#{sheet_name}シートの設定を取得できませんでした。" unless sheet_config
      row_offset = sheet_config['row_offset'] || 0
      mapping = sheet_config['mappings']

      # 設定ファイルにて定義した :row_offset から読み込み開始
      for i in (row_offset.to_i)..row_lengths
        row = sheet.getRow(i)
        next unless row.present?

        input = Input.new
        mapping.each do |key, option|
          raise "無効なExcelマッピング設定が与えられました" unless option && option.has_key?("index")
          value = get_cell_value(row.getCell(option["index"].to_i))
          input[key.to_s] = value
          input["no"] = value if option["key"]
        end
        input["resource_key"] = sheet_index
        input["process_info"] = get_process_info(sheet_name, (row_offset + i))
        yield input
      end
    end
    @workbook.close
  end

  # Cellから型変換した値を取得する
  #
  # @param [Java::OrgApachePoiXssfUsermodel::XSSFCell] cell セルオブジェクト
  # @return [mixed] 値
  def get_cell_value(cell)
    case @evaluator.evaluateInCell(cell).getCellType
    when Java::OrgApachePoiSsUsermodel::CellType::STRING
      (cell.getStringCellValue).to_s
    when Java::OrgApachePoiSsUsermodel::CellType::NUMERIC
      if DateUtil.isCellDateFormatted(cell)
        Time.at((cell.getDateCellValue).getTime / 1000).to_datetime
      else
        (cell.getNumericCellValue).to_i
      end
    when Java::OrgApachePoiSsUsermodel::CellType::BOOLEAN
      !!(cell.getBooleanCellValue)
    else
      nil
    end
  end

  private

  # Excelファイルを開く
  #
  # @private
  # @param [String] resource
  def open(resource)
    resource = resource.to_s
    raise "無効なExcelファイルが与えられました" unless %w[xls xlsx xlsm].include? File::extname(resource).gsub(".", '')
    stream = resource =~ URI::regexp ? URL.new(resource).openStream() : FileInputStream.new(resource)
    @workbook = WorkbookFactory::create(stream)
    @evaluator = @workbook.getCreationHelper.createFormulaEvaluator if @workbook.present?
  end

  # Excelの位置情報を作成
  #
  # @param [String] sheet_name シート名
  # @param [Integer] row_index 行番号
  # @return [Hash] Excelの処理位置情報
  def get_process_info(sheet_name, row_index)
    "#{sheet_name}シート, #{row_index}行目"
  end

  # 設定の正常性チェック
  #
  # @return [Boolean] 判定結果
  def valid_config?
    @config.each do |sheet, data|
      return false unless (sheet.to_s =~ /^[0-9]+$/) && data["mappings"].is_a?(Hash)
      return false unless (data["mappings"].find{|_, v| v.blank? || v["index"].blank?}).nil?
      data["mappings"] = Hash[data["mappings"].sort_by{|_, v| v["index"].to_i}]
    end
    true
  end
end
