/*


Cleaning Data in SQL Queries 


*/


select 
* from Project.dbo.Nashville_Housing



--- Standardize Date Format ---

select SaleDateConverted,CONVERT(Date,SaleDate)
from Project.dbo.Nashville_Housing


Update Project.dbo.Nashville_Housing
set SaleDate = CONVERT(date,saledate)

ALTER TABLE Project.dbo.Nashville_Housing
ADD SaleDateConverted Date;


Update Project.dbo.Nashville_Housing
set SaleDateConverted = CONVERT(Date,saledate)




----- Populate Property Address data   -----


select *
from Project.dbo.Nashville_Housing
--where PropertyAddress is null
order by ParcelID



select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,B.PropertyAddress)
from Project.dbo.Nashville_Housing a 
JOIN Project.dbo.Nashville_Housing b
		ON a.ParcelID = b.ParcelID
		AND a.[UniqueID ] <> b.[UniqueID ]
		where a.PropertyAddress is null



UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from Project.dbo.Nashville_Housing a
JOIN Project.dbo.Nashville_Housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
	where a.PropertyAddress is null




---   Breaking out Address into Individual Columns (Address, City, State)    ---


select PropertyAddress
from Project.dbo.Nashville_Housing
--where PropertyAddress is null
--order by ParcelID


Select 
Substring(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address
,Substring(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) Address

from Project.dbo.Nashville_Housing


ALTER TABLE Project.dbo.Nashville_Housing
ADD PropertySplitAddress Nvarchar(255);

Update Project.dbo.Nashville_Housing
set PropertySplitAddress = Substring(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE Project.dbo.Nashville_Housing
ADD PropertySplitcity Nvarchar(255);


Update Project.dbo.Nashville_Housing
set PropertySplitcity = Substring(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))


select *
from Project.dbo.Nashville_Housing


---- BREAKING OUT THE OWNER'S ADDRESS  ----

Select OwnerAddress 
From Project.dbo.Nashville_Housing


select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from Project.dbo.Nashville_Housing


ALTER TABLE Project.dbo.Nashville_Housing
ADD OwnerSplitAddress Nvarchar(255);

Update Project.dbo.Nashville_Housing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE Project.dbo.Nashville_Housing
ADD OwnerSplitcity Nvarchar(255);

Update Project.dbo.Nashville_Housing
set OwnerSplitcity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)


ALTER TABLE Project.dbo.Nashville_Housing
ADD OwnerSplitState Nvarchar(255);

Update Project.dbo.Nashville_Housing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)



select *
from Project.dbo.Nashville_Housing





--- Change Y and N to Yes and NO in "Sold as Vacant" in field  ---

Select Distinct(SoldAsVacant),COUNT(SoldAsVacant)
from Project.dbo.Nashville_Housing
GROUP BY SoldAsVacant
order by 2



Select SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' Then 'NO'
	ELSE SoldAsVacant
	END
from Project.dbo.Nashville_Housing


UPDATE Nashville_Housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
	END
	FROM  Project.dbo.Nashville_Housing





-- REMOVE DUPLICATES --


WITH RowNumCTE AS(
SELECT * ,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num

FROM Project.dbo.Nashville_Housing
--order by ParcelID
)
SELECT *
FROM RowNumCTE
where row_num > 1
order by PropertyAddress


Select *
from  Project.dbo.Nashville_Housing




---    DELETE Unused Columns      ---

SELECT *
FROM Project.dbo.Nashville_Housing

ALTER TABLE Project.dbo.Nashville_Housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE Project.dbo.Nashville_Housing
DROP COLUMN SaleDate