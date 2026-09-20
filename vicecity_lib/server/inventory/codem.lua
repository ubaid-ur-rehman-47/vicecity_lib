ViceCityCreateInventoryProvider('codem', 'codem-inventory', {
    items = 'GetInventory',
    add = 'AddItem',
    remove = 'RemoveItem',
    count = 'GetItemsTotalAmount',
    slot = 'GetItemBySlot',
    catalog = 'GetItemList',
    metadata = 'SetItemMetadata',
})
