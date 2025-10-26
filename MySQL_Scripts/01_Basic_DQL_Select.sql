-- ===================================================
-- 作業 1: 基礎 SELECT 與 DISTINCT
-- ===================================================

-- #01.請撰寫一select敘述，查詢Table:DEPT，列出所有資料列
SELECT *
FROM DEPT;

-- #02.請撰寫select敘述，查詢Table:EMP，列出所有員工的姓名(ENAME)、職稱(JOB)...
SELECT
    EMPNO,
    ENAME,
    JOB,
    HIREDATE
FROM EMP;

-- #03.請撰寫一select敘述，查詢Table:EMP，列出不同的到職日(HIREDATE)(去除重複的到職日)
SELECT DISTINCT
    HIREDATE
FROM
    EMP;
    
-- #04.續第02題，請將select敘述加上別名
SELECT
    EMPNO AS EmployeeNo,
    ENAME AS EmployeeName,
    JOB AS Title,
    HIREDATE AS HireDate
FROM EMP;

-- #05.請撰寫一select敘述，查詢Table:EMP，列出員工姓名(ENAME)串接職稱(JOB)
SELECT CONCAT(ENAME, ' (', JOB, ')') AS NAME_AND_TITLE
FROM EMP;


-- ===================================================
-- 作業 2: 條件過濾 (WHERE) 與排序 (ORDER BY)
-- ===================================================

-- #01.請列出薪資不介於1000到2000的員工之姓名和薪資
SELECT ENAME, SAL
FROM EMP
WHERE SAL
    NOT BETWEEN 1000 AND 2000;

-- #02.請列出到職年(到職日之年)為1981的員工之姓名、職稱、到職日，並依到職日遞減排序
-- 【審查建議】使用 YEAR() 函數比 LIKE 更標準，且能應對日期格式變動。
SELECT ENAME, JOB, HIREDATE
FROM EMP
WHERE
    YEAR(HIREDATE) = 1981
ORDER BY
    HIREDATE DESC;
    
-- #03.請列出薪資超過2000且部門編號為10或30的員工之姓名、薪資，並依序取別名為...
SELECT ENAME AS EMPLOYEE_NAME, SAL AS SALARY
FROM EMP
WHERE
    SAL > 2000 AND DEPTNO IN (10, 30);
    
-- #04.請列出有獎金(獎金不是null，也不是0)的員工之姓名、薪資、獎金，並排序，排序依據為..
SELECT ENAME, SAL, COMM
FROM EMP
WHERE
    COMM IS NOT NULL AND COMM <> 0
ORDER BY SAL + COMM;

-- #05.請列出員工姓名最後一個字是"S"的員工之姓名、職稱
SELECT ENAME, JOB
FROM EMP
WHERE
    ENAME LIKE '%S';
    
-- #06.請列出職稱為CLERK、SALESMAN，且薪資不等於1100、1300、1500的員工之姓名、職稱、薪資
SELECT ENAME, JOB, SAL
FROM EMP
WHERE
    JOB IN ('CLERK','SALESMAN')
    AND SAL NOT IN (1100, 1300, 1500);
    
-- #07.請列出獎金大於薪資1.05倍的員工之姓名、薪資、獎金
SELECT ENAME, SAL, COMM
FROM EMP
WHERE
    COMM > SAL * 1.05;
