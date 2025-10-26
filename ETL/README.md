01_ETL_Pipeline：交通數據擷取與雲端載入管道

專案目標

此數據管道（Data Pipeline）旨在實現高速公路即時交通數據的自動化擷取、清洗、彙總與持久化儲存。

核心功能包括：

Extract (擷取): 從交通部高速公路局 TISVCloud 平台爬取最新的 M05A（分區平均速率）CSV 檔案。

Transform (轉換): 使用 Pandas 進行數據清洗，過濾出特定的匝道 ID (TARGET_IDS)，並計算區段的平均速度及總車流量。

Load (載入): 將彙總後的結構化數據高效載入到 Google BigQuery 資料庫。

技術棧 (Tech Stack)

程式語言: Python

數據操作: Pandas (數據清洗、分組與彙總)

網路請求: Requests, BeautifulSoup (網頁爬蟲)

雲端服務: Google BigQuery (數據倉庫)

數據保留策略: SQL DML 語句 (自動管理數據筆數上限)

管道步驟詳解

1. E (Extract) - 數據擷取

腳本會鎖定當天的日期，並找到該日期下最新一小時所產生的 CSV 檔案連結。

使用 HTTP 請求下載檔案內容，並在記憶體中轉換為 Pandas DataFrame。

2. T (Transform) - 數據轉換

數據首先依據 GantryFrom 和 GantryTo 欄位進行分組。

聚合計算: * Speed (車速) 欄位取平均值。

Volume (車流量) 欄位取加總值。

過濾條件：只保留 GantryFrom 和 GantryTo 均在預定義的 TARGET_IDS 集合中的數據。

時間格式化：將時間戳記欄位處理為 BigQuery 需求的格式。

3. L (Load) - 數據載入與管理

數據保留 (Data Retention) 策略

在載入新數據前，腳本會查詢 BigQuery 資料表總筆數。

如果總筆數超過設定的 MAX_RECORDS (例如 40 筆)，腳本會自動執行 BigQuery SQL DELETE 查詢，刪除最舊的紀錄，確保資料庫大小受到控制。

數據寫入

使用 bigquery.Client().insert_rows_json() 方法，將清洗完畢的字典列表高效載入到目標資料表 (test_BQ_table)。

執行環境設定 (Configuration)

要運行此腳本，您需要：

安裝依賴套件:

pip install google-cloud-bigquery pandas requests beautifulsoup4


Google Cloud 憑證: * 您必須設定 GOOGLE_APPLICATION_CREDENTIALS 環境變數，指向您的 GCP 服務帳號金鑰檔案。

注意: 腳本中硬編碼了 project_id, dataset_id, 和 table_id，請確保這些值與您的 BigQuery 專案相符。
