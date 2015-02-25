package com.madhouse.spring.ds.Businesses;

import java.util.ArrayList;
import java.util.List;

/*{
 "data": [//BusinessesList
 {
 "name": "Madhouse",
 "id": "463893653751145"
 },//BusinessDetail
 {
 "name": "Madhousefmp",
 "id": "655204837919301"
 }//BusinessDetail
 ],
 "paging": {//Paging
 "next": "https://graph.facebook.com/v2.2/1383387821970508/businesses?access_token=CAALFqlUZB2acBAGpyNalvq7QoFPuuAeRta8Rqqy77GImZAha7FRczuhNZCPY3S1GIKsfDRRYbdNcbKDVXnPRkL7HA5jBmk9nNjTUnb2N888XUnLF5PypZCTts6udm2OobwnRMWgSg31qQvbkA5AKsDwXuUtbW09qXR9uZBn4NZCMO2bZALURiGrMna0CD2gTHvX9RyJaITrZApR6oGLaZBvLwtCnIIeU8uGgZD&limit=5000&offset=5000&__after_id=enc_AdCTaoVK5Jsu0GD9K3xkyrEhZAPZBV2CPWNzriy3gGAb3Oi71JT8aZCaNvLkpgjpmVRpwMygtkWa1RNxR8kyoZBQ6rPT"
 }
 }*/

/*public class Businesses {
 public List<BusinessDetail> d;
 public Paging p;
 public static class BusinessDetail{
 public String name;
 public String id;
 }
 public static class Paging{
 public String paging; 
 }
 }*/
public class Businesses {
	public List<Data> data;
	public Businesses() {
		super();
		// TODO Auto-generated constructor stub
	}

	public Paging paging;



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

}