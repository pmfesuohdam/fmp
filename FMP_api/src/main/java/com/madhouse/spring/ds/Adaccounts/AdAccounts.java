package com.madhouse.spring.ds.Adaccounts;

import java.util.List;

/*{
"data": [
    {
        "account_id": "655205154585936",
        "id": "act_655205154585936",
        "access_status": "CONFIRMED",
        "access_type": "OWNER",
        "permitted_roles": [
            "ADMIN",
            "GENERAL_USER",
            "REPORTS_ONLY"
        ]
    }
],
"paging": {
    "next": "https://graph.facebook.com/v2.2/655204837919301/adaccounts?access_token=CAALFqlUZB2acBAK3cmNZCpj2YHXyQ5m7ayXkuBETQkjWqhoLvM3BZB1j6yJZBGidGrhKlRzKfHZAxENYBELyB6tBgO6juhuczNdKXLIBKlcEJL5grKgm9unzZBZAVGuVk2nJntgjQ88uU0VQNw8DbKguFRdGiifLZBwa8IIfx7VPv7zbnXLY33QGstZBx7wOszMNV7LA2Y9OQZCandMu3HIN7gnikSK9yXv9IZD&limit=25&offset=25&__after_id=enc_AdAfp6uw46JvjRB7w8GToDmbr9kblShhmUXx7W1QmHnmZBpiSYCesfsk34QfKYyEHlhwMI1PS75JtYSdZCFxM9aNY5"
}
}*/
public class AdAccounts {
	public List<Data> data;
	public List<Data> getData() {
		return data;
	}
	public void setData(List<Data> data) {
		this.data = data;
	}
	public Paging getPaging() {
		return paging;
	}
	public void setPaging(Paging paging) {
		this.paging = paging;
	}
	public Paging paging;
}