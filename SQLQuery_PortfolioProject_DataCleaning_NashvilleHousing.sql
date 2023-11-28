--Cleaning Data in SQL Queries

SELECT *
FROM PortfolioProject_2.dbo.NashvilleHousing





-- 1. Standardize Date Format
SELECT
 SaleDateConverted
,CONVERT (date, SaleDate)
FROM PortfolioProject_2.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT (date, SaleDate)






-- 2. Populate Property Address data
SELECT *
FROM PortfolioProject_2.dbo.NashvilleHousing
WHERE PropertyAddress IS NULL


SELECT *
FROM PortfolioProject_2.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID


SELECT
 a.ParcelID
,a.PropertyAddress
,b.ParcelID
,b.PropertyAddress
,ISNULL(a.PropertyAddress,b.PropertyAddress)

FROM PortfolioProject_2.dbo.NashvilleHousing AS a
JOIN PortfolioProject_2.dbo.NashvilleHousing AS b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject_2.dbo.NashvilleHousing AS a
JOIN PortfolioProject_2.dbo.NashvilleHousing AS b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL






-- 3. Breaking out Property Address into Individual Columns (Address, City)
SELECT PropertyAddress
FROM PortfolioProject_2.dbo.NashvilleHousing


SELECT 
 PropertyAddress
,SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1) AS Address
,SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress))  AS Address

FROM PortfolioProject_2.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress))



SELECT *
FROM PortfolioProject_2.dbo.NashvilleHousing



-- 4. Breaking out Owner Address into Individual Columns (Address, City, State)
SELECT OwnerAddress
FROM PortfolioProject_2.dbo.NashvilleHousing


SELECT
 OwnerAddress
,PARSENAME(REPLACE(OwnerAddress, ',' , '.'),3)
,PARSENAME(REPLACE(OwnerAddress, ',' , '.'),2)
,PARSENAME(REPLACE(OwnerAddress, ',' , '.'),1)
FROM PortfolioProject_2.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' , '.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' , '.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',' , '.'),1)


SELECT *
FROM PortfolioProject_2.dbo.NashvilleHousing






-- 5. Change Y and N to Yes and No in "Sold as Vacant" field
SELECT DISTINCT(SoldAsVacant),Count(SoldAsVacant)
FROM PortfolioProject_2.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT 
 SoldAsVacant
,CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	  WHEN SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END
FROM PortfolioProject_2.dbo.NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	  WHEN SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END


SELECT DISTINCT(SoldAsVacant),Count(SoldAsVacant)
FROM PortfolioProject_2.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2






-- 6. Remove Duplicates
SELECT * 
FROM PortfolioProject_2.dbo.NashvilleHousing



WITH RowNumCTE AS (
SELECT * 
,ROW_NUMBER() OVER (
PARTITION BY ParcelID,
			 PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY
				UniqueID
				) row_num

FROM PortfolioProject_2.dbo.NashvilleHousing
)


--DELETE
--FROM RowNumCTE
--WHERE row_num > 1


SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress



-- 7. Delete Unused Columns

SELECT *
FROM PortfolioProject_2.dbo.NashvilleHousing


ALTER TABLE PortfolioProject_2.dbo.NashvilleHousing
DROP COLUMN
 OwnerAddress
,TaxDistrict
,PropertyAddress
,SaleDate




