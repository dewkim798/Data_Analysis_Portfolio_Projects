/*

Cleaning (Nashville Housing Dataset) with SQL Queries

*/

Select *
From PortfolioProject1.dbo.NashvilleHousingData



-- Standardizing the Date Format

Select SaleDate2, CONVERT(Date, SaleDate)
From PortfolioProject1.dbo.NashvilleHousingData

ALTER TABLE PortfolioProject1.dbo.NashvilleHousingData
Add SaleDate2 Date;

Update PortfolioProject1.dbo.NashvilleHousingData
SET SaleDate2 = CONVERT(Date, SaleDate)



-- Removing Duplicates

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
From PortfolioProject1.dbo.NashvilleHousingData
)
DELETE
From RowNumCTE
Where row_num > 1



-- Populating Property Address Data

Select *
From PortfolioProject1.dbo.NashvilleHousingData
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject1.dbo.NashvilleHousingData a
JOIN PortfolioProject1.dbo.NashvilleHousingData b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject1.dbo.NashvilleHousingData a
JOIN PortfolioProject1.dbo.NashvilleHousingData b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null



-- Separating the given PropertyAddress into the respective columns (Address, City)

Select PropertyAddress
From PortfolioProject1.dbo.NashvilleHousingData


Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
From PortfolioProject1.dbo.NashvilleHousingData


ALTER TABLE PortfolioProject1.dbo.NashvilleHousingData
Add SplitPropertyAddress Nvarchar(255);

ALTER TABLE PortfolioProject1.dbo.NashvilleHousingData
Add SplitPropertyCity Nvarchar(255);

Update PortfolioProject1.dbo.NashvilleHousingData
SET SplitPropertyAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

Update PortfolioProject1.dbo.NashvilleHousingData
SET SplitPropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))



-- Separating the given OwnerAddress into the respective columns (Address, City, State)

Select OwnerAddress
From PortfolioProject1.dbo.NashvilleHousingData


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From PortfolioProject1.dbo.NashvilleHousingData


ALTER TABLE PortfolioProject1.dbo.NashvilleHousingData
Add SplitOwnerAddress Nvarchar(255);

ALTER TABLE PortfolioProject1.dbo.NashvilleHousingData
Add SplitOwnerCity Nvarchar(255);

ALTER TABLE PortfolioProject1.dbo.NashvilleHousingData
Add SplitOwnerState Nvarchar(255);

Update PortfolioProject1.dbo.NashvilleHousingData
SET SplitOwnerAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

Update PortfolioProject1.dbo.NashvilleHousingData
SET SplitOwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

Update PortfolioProject1.dbo.NashvilleHousingData
SET SplitOwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



-- Replace the data of Y and N in "SoldAsVacant" Column to Yes and No

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject1.dbo.NashvilleHousingData
Group by SoldAsVacant
order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END 
From PortfolioProject1.dbo.NashvilleHousingData


Update PortfolioProject1.dbo.NashvilleHousingData
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END