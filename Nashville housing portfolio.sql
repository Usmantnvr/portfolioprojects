/* Cleaning data in SQL */

--Standardize Date format

SELECT *
FROM [Portfolio project I]..Sheet1$;

--Correct  Saledate format

SELECT SaleDate,CONVERT(date,SaleDate)
FROM [Portfolio project I]..Sheet1$;

ALTER TABLE Sheet1$
ADD SaleDate_Coreect_format DATE;

UPDATE [Portfolio project I]..Sheet1$
SET SaleDate_Coreect_format = CONVERT(date,SaleDate);

--Populate Property Address Area

SELECT *
FROM [Portfolio project I]..Sheet1$
--WHERE PropertyAddress is null
ORDER BY ParcelID;


SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.propertyAddress,b.PropertyAddress)
FROM [Portfolio project I]..Sheet1$ a
JOIN [Portfolio project I].. Sheet1$ b
ON a.ParcelID = b.ParcelID
AND   a.[UniqueID ] <> b.[UniqueID ]   
WHERE a.PropertyAddress is null;

UPDATE a
SET PropertyAddress = ISNULL(a.propertyAddress,b.PropertyAddress)
FROM [Portfolio project I]..Sheet1$ a
JOIN [Portfolio project I].. Sheet1$ b
ON a.ParcelID = b.ParcelID
AND   a.[UniqueID ] <> b.[UniqueID ]   
WHERE a.PropertyAddress is null;

--Breaking out Address into Individual columns(Address,City,State)

SELECT PropertyAddress
FROM [Portfolio project I]..Sheet1$;


--SELECT PropertyAddress,SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)) as Address,
--CHARINDEX(',',PropertyAddress)
--FROM [Portfolio project I]..Sheet1$

SELECT PropertyAddress,SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address,
       SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1 , LEN(PropertyAddress)) AS Address
FROM [Portfolio project I]..Sheet1$;



--Breaking out Address into Individual columns(Address,City,State) from owner'Address

SELECT OwnerAddress
FROM Sheet1$


SELECT OwnerAddress
FROM Sheet1$

SELECT OwnerAddress,
       PARSENAME(REPLACE(OwnerAddress,',','.'),3)
       PARSENAME(REPLACE(OwnerAddress,',','.'),2),
	   PARSENAME(REPLACE(OwnerAddress,',','.'),1)   
       FROM Sheet1$;

ALTER TABLE Sheet1$
ADD OwnerAdress_corrected nvarchar(255);

UPDATE Sheet1$
SET  OwnerAdress_corrected =PARSENAME(REPLACE(OwnerAddress,',','.'),3);

ALTER TABLE Sheet1$
ADD OwnerAdress_city_corrected nvarchar(255)

UPDATE Sheet1$
SET OwnerAdress_city_corrected  =PARSENAME(REPLACE(OwnerAddress,',','.'),2);

ALTER TABLE Sheet1$
ADD OwnerAdress_State_corrected nvarchar(255);

UPDATE Sheet1$
SET OwnerAdress_State_corrected =PARSENAME(REPLACE(OwnerAddress,',','.'),1);

--Change Y and N  to Yes  and No in'Sold as Vacant' field

SELECT Distinct(SoldAsVacant),COUNT(SoldAsVacant)
FROM Sheet1$
GROUP BY SoldAsVacant
--ORDER BY SoldAsVacant
ORDER BY 2 DESC

SELECT SoldAsVacant,
CASE When SoldAsVacant = 'Y' THEN 'YES'
     When SoldAsVacant = 'N' THEN 'NO'
     ELSE SoldAsVacant
	 END
FROM Sheet1$

UPDATE Sheet1$
SET SoldAsVacant= CASE When SoldAsVacant = 'Y' THEN 'YES'
     When SoldAsVacant = 'N' THEN 'NO'
     ELSE SoldAsVacant
	 END

	 --Removing Duplicates

	 WITH RowNumCTE AS(
SELECT *,
    ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference,
				 ORDER BY
				  UniqueID,
				  )row_num
FROM Sheet1$
)
DELETE 
FROM RowNumCTE
where row_num >1

SELECT*
FROM Sheet1$

