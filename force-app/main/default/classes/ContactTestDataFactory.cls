/**
 * @description generates contact data needed for testing
 * @author      M Rainboldt
 * @created     JUNE 2020
 */
@isTest(SeeAllData=false)
public with sharing class ContactTestDataFactory {
    static String defaultName = 'Test Contact';
    /**
	* @description      genreate a single contact record with the default record type
    * @return Contact   record with default record type, not committed (inserted) to database
	*/
    public static Contact generateContact(){
        return generateContact(null, defaultName + System.currentTimeMillis());
    }

    /**
    * @description      genreate a single contact record with the default record type and the specified last name
    * @param name       last name for contact
    * @return Contact   record with default record type, not committed (inserted) to database
	*/
    public static Contact generateContact(String name){
        return generateContact(null, name);
    }

    /**
    * @description          genreate a single contact record with the specified record type
    * @param recTypeName    name of the record type to assign the Contact
    * @param name           last name of the contact
    * @return Contact       record with specified record type, not committed (inserted) to database
	*/
    public static Contact generateContact(String recTypeName, String name){
        Contact testContact = new Contact(
            LastName = name
        );
        if(String.isNotBlank(recTypeName)){
            testContact.RecordTypeId = SObjectHelper.getRecordTypeID('Contact', recTypeName);
        }
        return testContact;
    }

    /**
    * @description          genreate a List of contact record with the specified record type and name + counter
    * @param num            number of records to generate
    * @param recTypeName    name of the record type to assign the Contact
    * @param name           last name of contacts with a counter
    * @return List of contact records with specified record type, not committed (inserted) to database
	*/
    public static List<Contact> generateContacts(Integer num, String recTypeName, String name){
        List<Contact> testContacts = new List<Contact>();
        Integer counter = 0;
        name = String.isBlank(name) ? defaultName : name;
        while(testContacts.size() < num){
            testContacts.add( generateContact(recTypeName, name + counter) );
            counter++;
        }
        return testContacts;
    }

    /**
    * @description                  genreate a List of contact record with the specified record type and name + counter
    * @param num                    number of records to generate
    * @param recTypeName            name of the record type to assign the Contact
    * @param name                   last name of contacts with a counter
    * @param generateDependencies   if true creates contacts
    * @return List of contact records with specified record type, not committed (inserted) to database
	*/
    public static List<Contact> generateContacts(Integer num, String recTypeName, String name, Boolean generateDependencies){
        List<Contact> testContacts = new List<Contact>();
        Integer counter = 0;
        name = String.isBlank(name) ? defaultName : name;
        List<Account> accounts = new List<Account>();
        if(generateDependencies)
        {
            accounts = AccountTestDataFactory.generateAccounts(num, recTypeName, name);
            insert accounts;
        }

        while(testContacts.size() < num){
            Contact contact = generateContact(recTypeName, name + counter);
            //set dependencies
            if(generateDependencies)
            {
                contact.AccountId = accounts[counter].Id;
            }

            testContacts.add(contact);
            counter++;
        }
        return testContacts;
    }

    
}