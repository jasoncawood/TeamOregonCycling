module Purchasable
  SKU_SEP = '-'

  extend ActiveSupport::Concern

  def sku
    [self.class.sku_item_type, id].join(SKU_SEP)
  end

  class_methods do
    def sku_item_type
      self::SKU_ITEM_TYPE
    end

    def sku_matches?(sku)
      sku =~ /^#{sku_item_type}#{SKU_SEP}/
    end
  end
end
