ViceCityCreateInventoryProvider('qs', 'qs-inventory', {
    items = 'GetInventory',
    add = 'AddItem',
    remove = 'RemoveItem',
    carry = 'CanCarryItem',
    count = 'GetItemTotalAmount',
    slot = 'GetItemBySlot',
    catalog = 'GetItemList',
    metadata = 'SetItemMetadata',
})
