-- CLEANING DATA
select * from Nashville_Housing;


-- Populate Property Address Data

select * from nashville_housing;


-- -- manueling changing blank cells to null
UPDATE
	nashville_housing
SET
    PropertyAddress = CASE PropertyAddress WHEN '' THEN NULL ELSE PropertyAddress END,
    OwnerName = CASE OwnerName WHEN '' THEN NULL ELSE OwnerName END,
    OwnerAddress = CASE OwnerAddress WHEN '' THEN NULL ELSE OwnerAddress END,
    TaxDistrict = CASE TaxDistrict WHEN '' THEN NULL ELSE TaxDistrict END;


select ifnull(a.PropertyAddress,b.PropertyAddress)
from nashville_housing as a
join nashville_housing as b
	on a.ParcelID = b.ParcelID and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null;


UPDATE nashville_housing a, nashville_housing b 
 SET 
     b.propertyaddress = a.propertyaddress
 WHERE
     b.propertyaddress IS NULL
         AND b.parcelid = a.parcelid
         AND b.propertyaddress is not null;



-- BREAKING UP THE PROPERTY ADDRESS INTO (ADDRESS,CITY,)

select PropertyAddress from nashville_housing;

select 
substring(PropertyAddress, 1, locate(',', PropertyAddress) - 1) as Address,
substring(PropertyAddress, locate(',', PropertyAddress) + 1, length(PropertyAddress)) as Address
from nashville_housing;

alter table nashville_housing
add PropertySplitAddress varchar(100);

Update nashville_housing
set PropertySplitAddress = substring(PropertyAddress, 1, locate(',', PropertyAddress) - 1);

alter table nashville_housing
add PropertySplitCity varchar(100);

Update nashville_housing
set PropertySplitCity = substring(PropertyAddress, locate(',', PropertyAddress) + 1, length(PropertyAddress));

-- Breaking Apart OWNER ADDRESS INTO (ADDRESS,CITY,STATE)

select OwnerAddress from nashville_housing;

SELECT 
SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 3), ',', -1),
SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1),
SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 1), ',', -1)
from nashville_housing;

alter table nashville_housing
add OwnerSplitAddress varchar(100), 
add OwnerSplitCity varchar(100), 
add OwnerSplitState varchar(100);

Update nashville_housing
set
OwnerSplitAddress = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 1), ',', -1),
OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1), 
OwnerSplitState = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 3), ',', -1);

select * from nashville_housing;



-- Changing Y and N to YES and NO respectivly in 'sold as vacant' field
select distinct(SoldAsVacant), count(SoldAsVacant)
from nashville_housing
group by SoldAsVacant;

select SoldAsVacant,
case 
	when SoldAsVacant = 'y' then 'Yes'
	when SoldAsVacant = 'n' then 'No'
    else SoldAsVacant
END
from nashville_housing
Order by 1;

Update nashville_housing
set SoldAsVacant = 
case 
	when SoldAsVacant = 'y' then 'Yes'
	when SoldAsVacant = 'n' then 'No'
    else SoldAsVacant
END;


         
-- Deleting Duplicating rows
with RowNumCTE as(
Select *, 
	row_number() over(
	partition by ParcelID,
				 PropertyAddress,
                 SalePrice,
                 SaleDate,
                 LegalReference
                 order by UniqueID) as row_num
from nashville_housing
)
delete from nashville_housing
Using nashville_housing
join RowNumCTE
on nashville_housing.UniqueID = RowNumCTE.UniqueID
where row_num > 1;





    



