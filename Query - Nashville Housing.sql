SELECT *
FROM `nashville_housing`.`nashville housing data for data cleaning`;

-- Standardize Date Format
SELECT SaleDate, 
       DATE_FORMAT(STR_TO_DATE(SaleDate, '%M %d, %Y'), '%d-%m-%Y') AS FormattedSaleDate
FROM `nashville_housing`.`nashville housing data for data cleaning`;


SET SQL_SAFE_UPDATES = 0;

UPDATE `nashville_housing`.`nashville housing data for data cleaning`
SET SaleDate = DATE_FORMAT(STR_TO_DATE(SaleDate, '%M %d, %Y'), '%d-%m-%Y');

SET SQL_SAFE_UPDATES = 1;

SELECT SaleDate
FROM `nashville_housing`.`nashville housing data for data cleaning`;

-- Populate Property Address data
Select *
From `nashville_housing`.`nashville housing data for data cleaning`
-- Where PropertyAddress is not null
order by ParcelID;

-- Populate Property Address data

SELECT a.ParcelID, 
       a.PropertyAddress, 
       b.ParcelID, 
       b.PropertyAddress, 
       IFNULL(a.PropertyAddress, b.PropertyAddress) AS MergedPropertyAddress
FROM `nashville_housing`.`nashville housing data for data cleaning` a
JOIN `nashville_housing`.`nashville housing data for data cleaning` b
	ON a.ParcelID = b.ParcelID
	AND a.`UniqueID` != b.`UniqueID`
WHERE a.PropertyAddress !='';


SET SQL_SAFE_UPDATES = 0;

UPDATE `nashville_housing`.`nashville housing data for data cleaning` a
JOIN `nashville_housing`.`nashville housing data for data cleaning` b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID != b.UniqueID
SET a.PropertyAddress = COALESCE(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress != '';

-- Breaking out Address into Individual Columns (Address, City, State)
SELECT PropertyAddress
FROM `nashville_housing`.`nashville housing data for data cleaning`;

SELECT
    SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1) AS AddressBeforeComma,
    SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1) AS AddressAfterComma
FROM 
    `nashville_housing`.`nashville housing data for data cleaning`;

ALTER TABLE `nashville_housing`.`nashville housing data for data cleaning`
ADD PropertySplitAddress VARCHAR(255) CHARACTER SET UTF8MB4;

SET SQL_SAFE_UPDATES = 0;

UPDATE `nashville_housing`.`nashville housing data for data cleaning`
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, INSTR(PropertyAddress, ',') - 1);

SET SQL_SAFE_UPDATES = 1;

ALTER TABLE `nashville_housing`.`nashville housing data for data cleaning`
ADD PropertySplitCity VARCHAR(255) CHARACTER SET UTF8MB4;

UPDATE `nashville_housing`.`nashville housing data for data cleaning`
SET PropertySplitCity = SUBSTRING(PropertyAddress, INSTR(PropertyAddress, ',') + 1, LENGTH(PropertyAddress));

SELECT 
SUBSTRING_INDEX(OwnerAddress, '.', -1) AS Part1
FROM `nashville_housing`.`nashville housing data for data cleaning`;

SELECT OwnerAddress
FROM `nashville_housing`.`nashville housing data for data cleaning`;

SELECT 
    SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -1) AS Part3,
    SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -2), '.', 1) AS Part2,
    SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -3), '.', 1) AS Part1
FROM `nashville_housing`.`nashville housing data for data cleaning`;

ALTER TABLE `nashville_housing`.`nashville housing data for data cleaning`
ADD OwnerSplitAddress VARCHAR(255) CHARACTER SET UTF8MB4;

ALTER TABLE `nashville_housing`.`nashville housing data for data cleaning`
Add OwnerSplitCity VARCHAR(255) CHARACTER SET UTF8MB4;

ALTER TABLE `nashville_housing`.`nashville housing data for data cleaning`
Add OwnerSplitState VARCHAR(255) CHARACTER SET UTF8MB4;

UPDATE `nashville_housing`.`nashville housing data for data cleaning`
SET 
    OwnerSplitAddress = SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', 1),
    OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -2), '.', 1),
    OwnerSplitState = SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -1);

Select *
From  `nashville_housing`.`nashville housing data for data cleaning`

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From `nashville_housing`.`nashville housing data for data cleaning`
Group by SoldAsVacant
order by 2

SELECT 
    SoldAsVacant,
    CASE 
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant 
    END AS SoldAsVacantFormatted
FROM `nashville_housing`.`nashville housing data for data cleaning`;

UPDATE `nashville_housing`.`nashville housing data for data cleaning`
SET SoldAsVacant = 
    CASE 
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant 
    END;

-- Remove Duplicates

SELECT t.*
FROM `nashville_housing`.`nashville housing data for data cleaning` t
JOIN (
    SELECT ParcelID,
           PropertyAddress,
           SalePrice,
           SaleDate,
           LegalReference,
           MIN(UniqueID) AS minUniqueID
    FROM `nashville_housing`.`nashville housing data for data cleaning`
    GROUP BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
    HAVING COUNT(*) > 1
) dup ON t.ParcelID = dup.ParcelID
      AND t.PropertyAddress = dup.PropertyAddress
      AND t.SalePrice = dup.SalePrice
      AND t.SaleDate = dup.SaleDate
      AND t.LegalReference = dup.LegalReference
      AND t.UniqueID <> dup.minUniqueID
ORDER BY t.PropertyAddress;

ALTER TABLE `nashville_housing`.`nashville housing data for data cleaning`
CHANGE COLUMN `ï»¿UniqueID` `UniqueID` INT; -- Change INT to the actual data type of UniqueID

-- Delete Unused Columns


Select *
From `nashville_housing`.`nashville housing data for data cleaning`


ALTER TABLE `nashville_housing`.`nashville housing data for data cleaning`
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict,
DROP COLUMN PropertyAddress,
DROP COLUMN SaleDate;

