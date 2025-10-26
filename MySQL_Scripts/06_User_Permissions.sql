-- ===================================================
-- 作業 10: 使用者管理與權限控制 (GRANT/REVOKE)
-- ===================================================

/* 01. 請利用Workbench建立一使用者帳號 (此處為文字說明，非SQL語法)
 * Username: william
 * Host: %
 * Password: P@ssw0rd
 */
-- 在 SQL 中，建立使用者並設定密碼的語法如下:
CREATE USER 'william'@'%' IDENTIFIED BY 'P@ssw0rd';


-- #02. 請授予使用者william對資料庫EXAMPLE底下所有資料表的所有權限
GRANT ALL PRIVILEGES
ON EXAMPLE.*
TO 'william'@'%';
-- 授予權限後，可能需要執行 FLUSH PRIVILEGES; 讓設定立即生效


-- #03. 請撤銷william對資料庫EXAMPLE底下所有資料表的所有權限
REVOKE ALL PRIVILEGES
ON EXAMPLE.*
FROM 'william'@'%';
