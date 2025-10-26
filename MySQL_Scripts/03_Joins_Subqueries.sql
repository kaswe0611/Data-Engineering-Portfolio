-- ===================================================
-- 作業 5: 聯結 (JOIN) 查詢
-- ===================================================

-- #01. 請列出所有員工的員工編號、姓名、職稱、部門編號及部門名稱
-- 【審查建議】雖然您的 Natural Join 語法正確，但通常更推薦使用 JOIN...ON 避免歧義。
SELECT
    E.EMPNO, E.ENAME, E.JOB, E.DEPTNO, D.DNAME
FROM
    EMP E
INNER JOIN
    DEPT D ON E.DEPTNO = D.DEPTNO;

-- #02. 請列出所有部門編號為30 且 職稱為"SALESMAN"之部門名稱、員工姓名、獎金
SELECT D.DNAME, E.ENAME, E.COMM
FROM EMP E
INNER JOIN DEPT D
    ON E.DEPTNO = D.DEPTNO
WHERE E.DEPTNO = 30 AND E.JOB = 'SALESMAN';

-- #03. 請列出薪水等級為"B"的員工之員工編號、員工姓名、薪資 (此題假設有 SALGRADE/SAL_LEVEL 表)
-- 【審查建議】此處假設存在 SAL_LEVEL 表，並使用 JOIN 連結薪資範圍。
SELECT
    E.EMPNO, E.ENAME, E.SAL
FROM
    EMP E
INNER JOIN
    SAL_LEVEL S ON E.SAL BETWEEN S.SAL_MIN AND S.SAL_MAX
WHERE
    S.LEVEL = 'B';
    
-- #04. 請列出部門編號、部門名稱及部門人數
SELECT
    D.DEPTNO, D.DNAME, COUNT(E.EMPNO) AS EmployeeCount
FROM
    DEPT D
INNER JOIN
    EMP E ON D.DEPTNO = E.DEPTNO
GROUP BY
    D.DEPTNO, D.DNAME;

-- #05. 請列出每個主管之姓名、直屬下屬人數、直屬下屬平均薪資，並依 直屬下屬人數遞減、主管姓名遞增 排序
SELECT
    B.ENAME AS 主管姓名,
    COUNT(A.EMPNO) AS 直屬下屬人數,
    AVG(A.SAL) AS 直屬下屬平均薪資
FROM
    EMP A -- A為下屬
LEFT JOIN
    EMP B ON A.MGR = B.EMPNO -- B為主子
WHERE B.ENAME IS NOT NULL -- 排除沒有主管的 KING
GROUP BY
    B.ENAME, A.MGR
ORDER BY
    直屬下屬人數 DESC,
    主管姓名 ASC;


-- ===================================================
-- 作業 6: 子查詢 (Subqueries)
-- ===================================================

-- #01. 請列出薪資比所有SALESMAN還低的員工
-- 使用 ALL 運算符 (或 MIN)
SELECT *
FROM EMP
WHERE SAL < ALL (
    SELECT SAL
    FROM EMP
    WHERE JOB = 'SALESMAN'
);

-- #02. 請列出到職年最早的兩年，那兩年到職的員工，並依到職日排序
-- 使用 derived table (子查詢作為資料表)
SELECT
    A.*
FROM
    EMP A
INNER JOIN
    (SELECT DISTINCT YEAR(HIREDATE) AS HIRE_YEAR
     FROM EMP
     ORDER BY HIRE_YEAR ASC
     LIMIT 2) B
ON YEAR(A.HIREDATE) = B.HIRE_YEAR
ORDER BY A.HIREDATE;

-- #03. 請列出主管的主管是 KING 的員工 (兩層間接主管)
SELECT
    E1.*
FROM
    EMP E1
WHERE
    E1.MGR IN ( -- 找出主管編號是誰
        SELECT EMPNO
        FROM EMP
        WHERE MGR = ( -- 找出 KING 的 EMPNO
            SELECT EMPNO
            FROM EMP
            WHERE ENAME = 'KING'
        )
    );

-- #04. 請列出部門內，員工薪資剛好有3種薪資等級之部門名稱、部門所在地
-- 【審查建議】您的寫法非常完美，使用了衍生表與 JOIN
SELECT DNAME, LOC
FROM DEPT D
JOIN (
    SELECT
        E.DEPTNO
    FROM
        EMP E
    JOIN
        SAL_LEVEL S ON E.SAL BETWEEN S.SAL_MIN AND S.SAL_MAX
    GROUP BY
        E.DEPTNO
    HAVING
        COUNT(DISTINCT S.LEVEL) = 3
) AS DeptWith3Levels
ON D.DEPTNO = DeptWith3Levels.DEPTNO;

-- #05. 請列出跟員工姓名最後一字元是S的員工同部門，該部門薪資最低的員工之部門名稱、姓名、 薪資
-- 使用 IN (多欄位子查詢)
SELECT D.DNAME, E.ENAME, E.SAL
FROM EMP E
JOIN DEPT D ON E.DEPTNO = D.DEPTNO
WHERE (E.DEPTNO, E.SAL) IN (
    -- 子查詢: 找出目標部門 (ENAME LIKE '%S') 中最低薪資的 (DEPTNO, MIN(SAL)) 組合
    SELECT DEPTNO, MIN(SAL)
    FROM EMP
    WHERE DEPTNO IN (SELECT DISTINCT DEPTNO FROM EMP WHERE ENAME LIKE '%S')
    GROUP BY DEPTNO
);
