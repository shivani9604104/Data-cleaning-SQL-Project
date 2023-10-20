CREATE DATABASE NASHOUSE ;
DROP DATABASE NASHOUSE;

use nashouse;

select * from nashville_housing
where OwnerAddress = '';
SET SQL_SAFE_UPDATES = 0;
UPDATE nashville_housing
SET OwnerAddress = NULL
WHERE OwnerAddress = '';
select column_name,data_type from information_schema.columns
where table_name = 'nashville_housing';
show table status from nashouse;

----------------------------- STANDRIZED DATE FORMATE-------------------------------------------------------------------------------------------------------------------------------------
SELECT DATE_FORMAT(STR_TO_DATE(SaleDate, '%M %e, %Y'), '%d-%m-%Y') 
from nashville_housing ;

UPDATE nashville_housing
SET SaleDate = DATE_FORMAT(STR_TO_DATE(SaleDate, '%M %e, %Y'), '%d-%m-%Y' )  ;

----------------------------------------------------- populate Propery Address -----------------------------------------------------------------------------------
select * from nashville_housing
where PropertyAddress is null;

select a.ParcelID,a.PropertyAddress ,b.ParcelID ,b.PropertyAddress , coalesce(a.PropertyAddress,b.PropertyAddress) from nashville_housing  a
join nashville_housing b on a.ParcelID = b.ParcelID and
               a.uniqueID<>b.uniqueID
where a.PropertyAddress is null;

UPDATE nashville_housing a
JOIN nashville_housing b ON a.ParcelID = b.ParcelID AND a.uniqueID <> b.uniqueID
SET a.PropertyAddress = COALESCE(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress IS NULL;

---------------------- -- BREAKING ADDRESS INTO INDIVIDUAL COLUMN (ADDRESS,CITY,STATE) ---------------------------------------------------------
SELECT
SUBSTRING_INDEX(PropertyAddress, ',', -1) as address
FROM nashville_housing;

ALTER TABLE nashville_housing
ADD PropertySplitAddress varchar(255);
UPDATE nashville_housing
SET PropertySplitAddress = SUBSTRING_INDEX(PropertyAddress, ',', 1) ;

ALTER TABLE nashville_housing
ADD PropertySplitCity varchar(255);
UPDATE nashville_housing
SET PropertySplitCity = SUBSTRING_INDEX(PropertyAddress, ',', -1) ;


-------------------------- BREAKING OWNER ADDRESS INTO INDIVIDUAL COLUMN (ADDRESS,CITY,STATE)---------------------------------------------------------------------
select 
trim(SUBSTRING_INDEX(OwnerAddress,',',1)),
trim(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', -2), ',', 1) )AS city
,trim(SUBSTRING_INDEX(OwnerAddress,',',-1))
-- SUBSTRING_INDEX(OwnerAddress,',',1)
from nashville_housing;


ALTER TABLE nashville_housing
ADD OwnerSplitAddress varchar(255);
UPDATE nashville_housing
SET OwnerSplitAddress = SUBSTRING_INDEX(PropertyAddress, ',', 1) ;

ALTER TABLE nashville_housing
ADD OwnerSplitCity varchar(255);
UPDATE nashville_housing
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', -2), ',', 1)  ;

ALTER TABLE nashville_housing
ADD OwnerSplitState varchar(255);
UPDATE nashville_housing
SET OwnerSplitState = SUBSTRING_INDEX(OwnerAddress,',',-1);
---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- change Y and N  to YES and NO in soldVsVacant

SELECT distinct(SoldAsVacant), count(SoldAsVacant)FROM nashville_housing
group by SoldAsVacant
order by 2 ;
-- USE CASE staement change

SELECT SoldAsVacant
,case when  SoldAsVacant ='Y' then 'Yes'
      when  SoldAsVacant ='N' then 'No'
      else SoldAsVacant
      end as s
FROM nashville_housing;

UPDATE nashville_housing
SET SoldAsVacant = (case when  SoldAsVacant ='Y' then 'Yes'
      when  SoldAsVacant ='N' then 'No'
      else SoldAsVacant
      end );
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------- REMOVE DUPLICATE------------------------------------------------------------------------------------------

SELECT * ,
 ROW_NUMBER() OVER (PARTITION BY ParcelID,
PropertyAddress,
SaleDate,
SalePrice,
LegalReference order by UniqueID) as row_num FROM nashville_housing
-- where row_num >2
-- order by ParcelID
;

----------------------------------------------------------------------- USE CTE----------------------------------------------------------------------------------

with Rownumcte as(
 SELECT * ,
 ROW_NUMBER() OVER (PARTITION BY ParcelID,
PropertyAddress,
SaleDate,
SalePrice,
LegalReference order by UniqueID) as row_num FROM nashville_housing)
select * from Rownumcte
where row_num >1
order by ParcelID;

-- if you found a duplicate than delete it by puting delete function istead of select function 

----------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- DELETE UNUSED COLUMN 
SELECT * FROM  nashville_housing;

ALTER TABLE nashville_housing
DROP COLUMN OwnerAddress;














