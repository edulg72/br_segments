insert into segments_historico (id,latitude,longitude,length,level,last_edit_on,last_edit_by,lock,connected,street_id,roadtype,fwdmaxspeed,revmaxspeed,fwddirection,revdirection,city_id,cross_segment,roundabout,alt_names,validated,toll,flags,created_at)
  select id,latitude,longitude,length,level,last_edit_on,last_edit_by,lock,connected,street_id,roadtype,fwdmaxspeed,revmaxspeed,fwddirection,revdirection,city_id,cross_segment,roundabout,alt_names,validated,toll,flags,current_timestamp
  from
    (select id,latitude,longitude,length,level,last_edit_on,last_edit_by,lock,connected,street_id,roadtype,fwdmaxspeed,revmaxspeed,fwddirection,revdirection,city_id,cross_segment,roundabout,alt_names,validated,toll,flags
     from segments
     except
     select sh.id,latitude,longitude,length,level,last_edit_on,last_edit_by,lock,connected,street_id,roadtype,fwdmaxspeed,revmaxspeed,fwddirection,revdirection,city_id,cross_segment,roundabout,alt_names,validated,toll,flags
     from segments_historico as sh,
       (select id, max(created_at) as created_at
        from segments_historico
        group by id
        ) as last
     where sh.id = last.id
      and sh.created_at = last.created_at) as updates;

insert into streets_historico (id,name,isempty,city_id,created_at)
  select id,name,isempty,city_id,current_timestamp
  from
    (select id,name,isempty,city_id
     from streets
     except
     select sh.id,name,isempty,city_id
     from streets_historico as sh,
       (select id, max(created_at) as created_at
        from streets_historico
        group by id
        ) as last
     where sh.id = last.id
      and sh.created_at = last.created_at) as updates;
