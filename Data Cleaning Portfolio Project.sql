-- DATA CLEANING PORTFOLIO PROJECT
-- AUTHOR: ALEX ALLAN

------------------------------------------------------------------------------------------------------------------------

SELECT * 
  FROM DataCleaningProject.dbo.NashvilleHousing

-- Standardize Date Format

SELECT SaleDate, CONVERT(Date, SaleDate) AS what_we_want
  FROM DataCleaningProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate =  CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted =  CONVERT(Date, SaleDate)

-------------------------------------------------------------------------------------------------------------------------

-- Populate Propert Addresss Data

SELECT *
FROM DataCleaningProject.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM DataCleaningProject.dbo.NashvilleHousing AS a
JOIN DataCleaningProject.dbo.NashvilleHousing AS b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM DataCleaningProject.dbo.NashvilleHousing AS a
JOIN DataCleaningProject.dbo.NashvilleHousing AS b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-----------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State) using SUBSTRING and CHARINDEX

SELECT *
FROM DataCleaningProject.dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress)-1) AS address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+ 1, LEN(PropertyAddress)) AS address
FROM DataCleaningProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress =  SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity =  SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+ 1, LEN(PropertyAddress))

------------------------------------------------------------------------------------------------------------------------

-- Cleaning up column 'OwnerAddress' using PARSENAME

SELECT *
FROM DataCleaningProject.dbo.NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
FROM DataCleaningProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerAddressSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerAddressSplitAddress =  PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerAddressSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerAddressSplitCity =  PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerAddressSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerAddressSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)

---------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM DataCleaningProject.dbo.NashvilleHousing
GROUP BY SoldASVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
END
FROM DataCleaningProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = 
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
END

--------------------------------------------------------------------------------------------------------

-- Remove Duplicates using CTE

WITH RowNumCTE AS(
 SELECT *, 
		ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 ORDER BY
					 UniqueID
					 ) row_num
			
 FROM DataCleaningProject.dbo.NashvilleHousing
 )

DELETE
FROM RowNumCTE
WHERE row_num > 1

-------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT *
FROM DataCleaningProject.dbo.NashvilleHousing

ALTER TABLE DataCleaningProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE DataCleaningProject.dbo.NashvilleHousing
DROP COLUMN SaleDate
