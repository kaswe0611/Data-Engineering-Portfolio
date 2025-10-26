-- ===================================================
-- 作業 7: 數據操作語言 (DML: INSERT, UPDATE, DELETE)
-- ===================================================

/* 01. 請新增以下資料至資料表DEPT: 50, 'Software', 'Taipei' */
INSERT INTO
	DEPT
VALUES
	(50, 'Software', 'Taipei');


/* 02. 請新增以下資料至資料表EMP的欄位EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, DEPTNO */
INSERT INTO
	EMP(EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, DEPTNO)
VALUES
	(9999, 'William', 'PG', NULL, NOW(), 2500, 50),
	(8888, 'Lee', 'PM', NULL, NOW(), 3500, 50);


/* 03. 請修改資料表EMP的資料..
 * 將員工8888 的主管 改為 7839
 * 將員工9999 的主管 改為 8888
 */
UPDATE
	EMP
SET
	MGR = 7839
WHERE
	EMPNO = 8888;
    
UPDATE
	EMP
SET
	MGR = 8888
WHERE
	EMPNO = 9999;
    

-- #04. 請刪除員工編號為8888的員工之資料
DELETE FROM EMP
WHERE EMPNO = 8888;

/* 05. 請列出修改資料表EMP的資料..
 * 將員工9999 的主管 改為 7839，薪水 改為 4000
 */
UPDATE
	EMP
SET
	MGR = 7839,
    SAL = 4000
WHERE
	EMPNO = 9999;


-- ===================================================
-- 作業 8: 交易控制 (Transactions)
-- ===================================================

/* 01. 請啟用交易控制模式，執行以下動作..
 * 刪除除了老闆以外的所有員工之資料列
 * 查詢確認是否已刪除
 * 還原
 */
-- 在 MySQL 中，可以通過 SET AUTOCOMMIT=0 啟用手動交易
SET AUTOCOMMIT = 0;
START TRANSACTION; -- 也可以明確開始
    DELETE FROM
		EMP
	WHERE
		MGR IS NOT NULL;
	SELECT * FROM EMP;
ROLLBACK;
SET AUTOCOMMIT = 1; -- 結束手動模式，恢復自動提交

/* 02. 請開啟單一交易控制，執行以下動作..
 * 修改除了老闆以外的所有員工，獎金+1000、薪水+15%
 * 查詢確認是否已修改
 * 送交
 */
START TRANSACTION;
	UPDATE
		EMP
	SET
		SAL = SAL * 1.15,
		COMM = IFNULL(COMM, 0) + 1000 -- 使用 IFNULL 確保 COMM 為 NULL 時能正確加總
	WHERE
		MGR IS NOT NULL;
	SELECT * FROM EMP;
COMMIT;


/* 03. 今天公司空降了一位主管ERIC，員工編號: 6666，職稱: MANAGER，主管: 7839，薪資: 3500，部門編號: 50。
 * 另外原本就在職的2位員工7499、7844調至部門編號50，且主管改為6666。
 * 請開啟單一交易控制，將上述動作在一個交易內完成
 */	
START TRANSACTION;
	-- 插入新員工 ERIC (COMM 欄位在此處寫入 NULL)
	INSERT INTO
	EMP(EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, COMM, DEPTNO)
	VALUES
	(6666, 'ERIC', 'MANAGER', 7839, NOW(), 3500, NULL, 50);
	
	-- 更新兩位員工
	UPDATE
		EMP
	SET
		DEPTNO = 50,
		MGR = 6666
	WHERE
		EMPNO IN (7499,7844);
	
	SELECT * FROM EMP; -- 確認變更
ROLLBACK; -- 執行完畢後選擇 ROLLBACK 或 COMMIT
