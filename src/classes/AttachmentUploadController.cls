/**
 * Attachments upload controller
 */
public with sharing class AttachmentUploadController {
	public Attachment attachment {
		get {
			if (attachment == null)
				attachment = new Attachment();
			return attachment;
		}
		set;
	}

	public String sObjectName {get; set;}
	public String sObjectId {get; set;}

	/**
	 * Upload attachment
	 * @return  null
	 */
	public PageReference upload() {
		attachment.OwnerId = UserInfo.getUserId();
		attachment.ParentId = sObjectId;
		attachment.IsPrivate = true;
		try {
			insert attachment;
		} 
		catch(DmlException e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Ooops! Error uploading attachment'));
			return null;
		} 
		finally {
			this.attachment = new Attachment();
		}
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Yay! Attachment uploaded successfully'));
		return null;
	}

	/**
	 * sObject select options
	 * @return  picklist array
	 */
	public List<SelectOption> getObjects() {
		List<SelectOption> stdObjectNames = new List<SelectOption>();
		List<AllowUploads__c> sforceObjects = AllowUploads__c.getAll().values();
		stdObjectNames.add(new SelectOption('', '--Selezione--'));
		for (Schema.SObjectType typ : Schema.getGlobalDescribe().values()) {
			String sobjName = String.valueOf(typ);
			if (!sobjName.endsWith('__c')) {
				if (AttachmentUploadController.contains(sforceObjects, sobjName)) {
					stdObjectNames.add(new SelectOption(sobjName, sobjName));
				}
			}
		}
		return stdObjectNames;
	}

	/**
	 * Records select options
	 * @return  picklist array
	 */
	public List<SelectOption> getRecords() {
		String Query = '';
		List<SelectOption> sfdcRecordNames = new List<SelectOption>();
		sfdcRecordNames.add(new SelectOption('', '--Selezione--'));
		if (String.isNotEmpty(sObjectName)) {
			Query = 'Select ' + AttachmentUploadController.getObjectFields(sObjectName) + ' from ' + sObjectName;
			if (Query.contains('name')) {
				Query += ' order by Name limit 200';
				List<sObject> sObjFields = Database.query(Query);
				for (sObject obj : sObjFields) {
					String value = String.valueOf(obj.get('id'));
					String label = String.valueOf(obj.get('name'));
					sfdcRecordNames.add(new SelectOption(value, label));
				}
			}		
		}
		return sfdcRecordNames;
	}

	/**
	 * Contains utility function
	 * @param  items  list of elements
	 * @param  item   item to found in list
	 * @return       if element was found
	 */
	public static Boolean contains(List<AllowUploads__c> items, String item) {
		for (AllowUploads__c i : items) {
			if (i.Name.equals(item)) {
				return true;
			}
		}
		return false;
	}


	public static String getObjectFields(String objName) {
        String fieldnames = '';
        Map<String,Schema.SObjectType> m = Schema.getGlobalDescribe();
        Schema.SObjectType s = m.get(objName);
        Schema.DescribeSObjectResult r = s.getDescribe();
        Map<String,Schema.SObjectField> fields = r.fields.getMap();
        for (string field : fields.keySet()) {
            if (fieldnames.equals('')) {
                fieldnames = field;
            } else {
                fieldnames += ',' + field;
            }
        }
        return fieldnames;
    }
}