using { API_BUSINESS_PARTNER as external } from './external/API_BUSINESS_PARTNER.csn';

/**
 * Tailor the imported API to our needs...
 */
extend service API_BUSINESS_PARTNER with {

  /**
   * Simplified view on external addresses
   */
  @mashup entity Addresses as projection on external.A_BusinessPartnerAddress {
    key BusinessPartner as contact,
    key AddressID as ID,
    Country as country,
    CityName as cityName,
    PostalCode as postalCode,
    StreetName as streetName,
    HouseNumber as houseNumber
  }

  /**
   * Re-modelling the event which is currently not available declaratively from S/4
   */
  entity BusinessPartner as projection on external.A_BusinessPartner;
  @messaging.topic:'${prefix}/BusinessPartner/Changed'
  event BusinessPartner_CHANGED {
    _KEY: array of {
      BUSINESSPARTNER : external.A_BusinessPartner.BusinessPartner
    }
  }

}


/**
 * Add an entity to replicate external address data for quick access,
 * e.g. when displaying lists of orders.
 */
@cds.persistence:{table,skip:false} //> create a table with the view's inferred signature
@cds.autoexpose //> auto-expose in services as targets for ValueHelps and joins
entity sap.capire.bookshop.Addresses as SELECT from external.Addresses { *,
  false as tombstone : Boolean
};


/**
 * Extend Orders with references to replicated external Addresses
 */
using { sap.capire.bookshop } from '../db/schema';
extend bookshop.Orders with {
  shippingAddress : Association to bookshop.Addresses;
}
