/*

Cleaning Data in SQL Queries

*/
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing


-- Standardize Date Format

SELECT SaleDate, CONVERT(DATE,SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing

--1st way (SOMETIMES NOT WORKING)
UPDATE NashvilleHousing
SET SaleDate = CONVERT(DATE,SaleDate)

SELECT SaleDate, CONVERT(DATE,SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing

--2nd way - alternative
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD SaleDateConverted DATE;

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(DATE,SaleDate)

SELECT SaleDateConverted, CONVERT(DATE,SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing


-- Populate Property Address Data

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing
WHERE PropertyAddress IS NULL

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
WHERE PropertyAddress IS NULL  

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

--(JOIN within the SAME table but with different distinguish. in this case colum UniqueID)
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL (a.PropertyAddress,b.PropertyAddress)  
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

--(check it again)
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID

--SHOW DATA UNTIL (' '), IN THE EXAMPLE IS COMA (',') 
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) AS Address

FROM PortfolioProject.dbo.NashvilleHousing

--SHOW DATA UNTIL (' '), IN THE EXAMPLE IS COMA (',') AND SHOW THE ROW OF COMA
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) AS Address,
CHARINDEX(',', PropertyAddress)

FROM PortfolioProject.dbo.NashvilleHousing

--ERASING THE (' ')
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1 ) AS Address

FROM PortfolioProject.dbo.NashvilleHousing

--new column address only (without coma), new city column (without coma)

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From PortfolioProject.dbo.NashvilleHousing


--Update it into the table

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

Select *
From PortfolioProject.dbo.NashvilleHousing

--SEPERATING ADDRESS WITH PARSENAME
Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

 -- SINCE PARSNAME ONLY ELIGIBLE FOR DOT  (.), IT NEEDS TO REPLACE COMA WITH DOT FIRST.
 Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
From PortfolioProject.dbo.NashvilleHousing

--THE FIRST ONE GOES BACKWARDS. HENCE NEED TO WRITE THE NUBER BACKWARD

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject.dbo.NashvilleHousing

--UPDATE IT INTO TABLE
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From PortfolioProject.dbo.NashvilleHousing


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject.dbo.NashvilleHousing

Update PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From PortfolioProject.dbo.NashvilleHousing
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

--DELETE IT
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From PortfolioProject.dbo.NashvilleHousing
)
DELETE
From RowNumCTE
Where row_num > 1

--THE RESULT
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From PortfolioProject.dbo.NashvilleHousing
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress




--DELETE UNUSED COLUMN (PLEASE BE WISE ABOUT THIS CAAUSE THERE'S NO GOING BACK)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

Select *
From PortfolioProject.dbo.NashvilleHousing