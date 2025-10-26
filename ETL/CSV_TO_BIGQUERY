import os
import csv
from google.cloud import bigquery
import requests
import pandas as pd
from bs4 import BeautifulSoup
from urllib.parse import urljoin, urlparse
from datetime import datetime
from io import StringIO

# 設定你的GCP憑證與專案資訊
os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = r"C:\Users\user\Desktop\測試bigquery\test-bigquery-468412-88f698064d4f.json" 
project_id = 'test-bigquery-468412' # 替換為你的專案ID
dataset_id = 'test_BQ'  
table_id = 'test_BQ_table'

# 設定要保留的資料筆數
MAX_RECORDS = 40
# 假設你的時間戳記欄位名稱是 'timestamp'
TIMESTAMP_FIELD = 'TimeStamp' 

# 建立 BigQuery 客戶端物件
client = bigquery.Client(project=project_id)
table_ref = client.dataset(dataset_id).table(table_id)

BASE_URL = "https://tisvcloud.freeway.gov.tw/history/TDCS/M05A/"
COLUMNS = ["TimeStamp", "GantryFrom", "GantryTo", "VehicleType", "Speed", "Volume"]
TARGET_IDS = {"05F0287N", "05F0055N", "05F0001N"}

def manage_data_retention(client, table_ref, max_records):
    """
    檢查資料表筆數，如果超過限制，刪除最舊的資料。
    """
    # 1. 查詢目前的資料筆數
    query = f"SELECT COUNT(*) AS total_rows FROM `{table_ref.project}.{table_ref.dataset_id}.{table_ref.table_id}`"
    query_job = client.query(query)
    result = query_job.result()
    total_rows = next(result).total_rows
    
    print(f"目前資料表中共有 {total_rows} 筆資料。")
    
    # 2. 如果筆數超過或等於上限，則刪除多餘的資料
    if total_rows >= max_records:
        rows_to_delete = total_rows - max_records + 1 # 刪除多餘的，並為新資料騰出一個位置
        print(f"資料筆數超過上限，將刪除最舊的 {rows_to_delete} 筆資料。")
        
        # 刪除最舊的資料
        delete_query = f"""
        DELETE FROM `{table_ref.project}.{table_ref.dataset_id}.{table_ref.table_id}`
        WHERE {TIMESTAMP_FIELD} IN (
            SELECT {TIMESTAMP_FIELD}
            FROM `{table_ref.project}.{table_ref.dataset_id}.{table_ref.table_id}`
            ORDER BY {TIMESTAMP_FIELD} ASC
            LIMIT {rows_to_delete}
        )
        """
        delete_job = client.query(delete_query)
        delete_job.result()
        print("最舊的資料已刪除。")


# === 工具: 抓取 HTML 連結 ===
def get_links_by_suffix(url, suffix):
    res = requests.get(url, verify=False)
    if res.status_code != 200:
        print(f"❌ 連線失敗: {url} ({res.status_code})")
        return []
    soup = BeautifulSoup(res.text, "html.parser")
    return [
        urljoin(url, a["href"])
        for td in soup.find_all("td", class_="indexcolname")
        for a in td.find_all("a")
        if a["href"].endswith(suffix)
    ]

# === 抓今天最新CSV連結 ===
def get_latest_csv_link():
    today_str = datetime.now().strftime("%Y%m%d") # ← 抓今天日期
    date_url = urljoin(BASE_URL, today_str + "/") # ← 拼出今天的資料夾網址

    hour_folders = get_links_by_suffix(date_url, "/") # ← 抓今天底下所有小時資料夾
    if not hour_folders:
        print("⚠️ 無法取得小時資料夾")
        return None, None

    latest_hour_url = sorted(hour_folders)[-1] # ← 挑最晚的一小時資料夾
    csv_links = get_links_by_suffix(latest_hour_url, ".csv") # ← 抓這個小時的所有 CSV
    if not csv_links:
        print("⚠️ 沒有找到CSV檔")
        return None, None

    return sorted(csv_links)[-1]


# === 下載與過濾資料 ===
def process_data_from_url():
    """
    從遠端網址抓取、過濾並分組統計資料。
    """
    csv_url = get_latest_csv_link()
    if not csv_url:
        print("❌ 沒有最新 CSV 檔案")
        return None
    
    try:
        print(f"⬇️ 下載最新檔案：{csv_url}")
        r = requests.get(csv_url,verify=False, timeout=20)
        if r.status_code != 200:
            print(f"❌ 無法下載: {csv_url}")
            return None
        df = pd.read_csv(StringIO(r.text), header=None)
        if df.shape[1] != 6:
            print("⚠️ 欄位數量錯誤")
            return None
        df.columns = COLUMNS
        # ➤ 過濾：GantryFrom ∈ TARGET_IDS 且 Speed ≠ 0
        df = df[(df["GantryFrom"].isin(TARGET_IDS)) & (df["Speed"] != 0)]
        if df.empty:
            print("⚠️ 無可用資料進行統計")
            return None
        grouped = df.groupby(["GantryFrom", "GantryTo"]).agg({
            "Speed": "mean",
            "Volume": "sum"
        }).reset_index()

        # ✅ 新增過濾：只保留 GantryTo ∈ TARGET_IDS
        grouped = grouped[grouped["GantryTo"].isin(TARGET_IDS)]

        # ➤ 取得時間（第一筆）
        # timestamp = pd.to_datetime(df["TimeStamp"].iloc[0])
        # grouped.insert(0, "TimeStamp", timestamp)
        grouped['TimeStamp'] = pd.to_datetime(df["TimeStamp"].iloc[0])

        grouped['Date'] = grouped['TimeStamp'].dt.strftime('%Y-%m-%d')
        grouped['Time'] = grouped['TimeStamp'].dt.strftime('%H:%M')

        grouped['TimeStamp'] = grouped['TimeStamp'].dt.strftime('%Y-%m-%d %H:%M:%S')

        print("📊 分組統計結果（Speed 平均, Volume 加總）：")
        print(grouped)

        return grouped.to_dict('records') # 轉換成 BigQuery 接受的字典列表格式
    
    except Exception as e:
        print(f"⚠️ 資料處理失敗：{e}")
        return None
    
def upload_to_bigquery(rows_to_insert):
    """
    將資料匯入 BigQuery 資料表。
    """
    if not rows_to_insert:
        print("沒有資料可供匯入。")
        return
    
    try:

        for row in rows_to_insert:
            # 執行型態轉換
            row['Speed'] = int(float(row['Speed']))
            row['Volume'] = int(float(row['Volume']))

        errors = client.insert_rows_json(table_ref, rows_to_insert)
        
        if errors:
            print(f"資料匯入時發生錯誤: {errors}")
        else:
            print(f"成功匯入 {len(rows_to_insert)} 筆資料到 BigQuery。")
    except Exception as e:
        print(f"匯入過程中發生異常: {e}")

if __name__ == '__main__':
    # 1. 管理資料保留策略：如果超過40筆，則刪除最舊的
    manage_data_retention(client, table_ref, MAX_RECORDS)
    
    # 2. 抓取最新資料 (這裡使用 CSV 模擬)
    new_data = process_data_from_url()

    # 3. 匯入 BigQuery
    if new_data:
        upload_to_bigquery(new_data)
