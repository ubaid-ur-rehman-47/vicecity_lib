ViceCityCreateInventoryProvider('core', 'core_inventory', {
    items = 'getInventory',
    add = 'addItem',
    remove = 'removeItem',
    carry = 'canCarry',
    count = 'getItemCount',
    slot = 'getItemBySlot',
    catalog = 'getItemsList',
    durability = 'setDurability',
})
