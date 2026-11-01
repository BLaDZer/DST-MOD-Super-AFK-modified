--Drops Reset Countdown Steam Workshop Page: https://steamcommunity.com/sharedfiles/filedetails/?id=1688661034
--Website Version: https://dst-skins-checklist.firebaseapp.com/drops
--Created by Instant Noodles: https://steamcommunity.com/id/instant-noodles
--This mod may not be copied, altered, or reproduced in any way without the explicit and prior permission of the author

function ldateFormat(unix, units, lang, format, type)
  local ttbl=tonumber(unix)>0 and os.date("*t", unix) or os.date("*t", 0)
  local hour_12=ttbl.hour>12 and ttbl.hour-12 or ttbl.hour==0 and 12 or ttbl.hour
  local ampm=ttbl.hour<12 and units.time[lang][1] or units.time[lang][2]

  if (type=="full" or type=="fullb") then  
    if (lang=="RU") then
      ampm=(ttbl.hour>=5 and ttbl.hour<12) and units.time[lang][1] or (ttbl.hour>=12 and ttbl.hour<17) and units.time[lang][2] or (ttbl.hour>=17 and ttbl.hour<24) and units.time[lang][3] or units.time[lang][4]
      local weekday=type=="full" and units.wdays[lang][ttbl.wday]..", " or ""
      local output=weekday..ttbl.day.." "..units.months[lang][ttbl.month].." "..ttbl.year.." "..units.yearsuffix[lang]

      return format=="12" and (output.." "..hour_12..":"..string.format("%02d", ttbl.min)..":"..string.format("%02d", ttbl.sec).." "..ampm) or (output.." "..string.format("%02d", ttbl.hour)..":"..string.format("%02d", ttbl.min)..":"..string.format("%02d", ttbl.sec))
    elseif (lang=="ZH" or lang=="ZT" or lang=="KO") then
      local weekday=type=="full" and units.wdayprefix[lang]..units.wdays[lang][ttbl.wday]..units.wdaysuffix[lang] or ""
      local output=ttbl.year..units.yearsuffix[lang]..ttbl.month..units.monthsuffix[lang]..ttbl.day..units.daysuffix[lang].." "..weekday

      return format=="12" and (output.." "..ampm..hour_12..":"..string.format("%02d", ttbl.min)..":"..string.format("%02d", ttbl.sec)) or (output.." "..string.format("%02d", ttbl.hour)..":"..string.format("%02d", ttbl.min)..":"..string.format("%02d", ttbl.sec))
    elseif (lang=="PT") then
      local weekday=type=="full" and units.wdays[lang][ttbl.wday]..", " or ""
      local output=weekday..ttbl.day.." "..units.months[lang][ttbl.month].." "..ttbl.year

      return format=="12" and (output.." "..hour_12..":"..string.format("%02d", ttbl.min)..":"..string.format("%02d", ttbl.sec).." "..ampm) or (output.." "..string.format("%02d", ttbl.hour)..":"..string.format("%02d", ttbl.min)..":"..string.format("%02d", ttbl.sec))
    elseif (lang=="EU") then
      return format=="12" and string.gsub(os.date("%a, %d %b %Y %I:%M:%S %p", unix), " 0(%d)", " %1") or os.date("%a, %d %b %Y %H:%M:%S", unix)
    else
      return format=="12" and string.gsub(os.date("%a, %b %d, %Y %I:%M:%S %p", unix), " 0(%d)", " %1") or os.date("%a, %b %d, %Y %H:%M:%S", unix)
    end
  elseif (type=="md") then
    if (lang=="RU" or lang=="PT") then
      return ttbl.day.." "..units.months[lang][ttbl.month]
    elseif (lang=="ZH" or lang=="ZT" or lang=="KO") then
      return ttbl.month..units.monthsuffix[lang]..ttbl.day..units.daysuffix[lang]
    elseif (lang=="EU") then
      return string.gsub(os.date("%d %b", unix), "0(%d)", "%1")
    else
      return string.gsub(os.date("%b %d", unix), " 0(%d)", " %1")
    end
  elseif (type=="wd") then
    return units.wdayprefix[lang]..units.wdayslong[lang][ttbl.wday]..units.wdaysuffix[lang]
  elseif (type=="wdmdy") then
    if (lang=="RU") then
      return units.wdays[lang][ttbl.wday]..", "..ttbl.day.." "..units.months[lang][ttbl.month].." "..ttbl.year.." "..units.yearsuffix[lang]
    elseif (lang=="ZH" or lang=="ZT" or lang=="KO") then
      return ttbl.year..units.yearsuffix[lang]..ttbl.month..units.monthsuffix[lang]..ttbl.day..units.daysuffix[lang].." "..units.wdayprefix[lang]..units.wdays[lang][ttbl.wday]..units.wdaysuffix[lang]
    elseif (lang=="PT") then
      return units.wdays[lang][ttbl.wday]..", "..ttbl.day.." "..units.months[lang][ttbl.month].." "..ttbl.year
    elseif (lang=="EU") then
      return string.gsub(os.date("%a, %d %b %Y", unix), " 0(%d)", " %1")
    else
      return string.gsub(os.date("%a, %b %d, %Y", unix), " 0(%d)", " %1")
    end
  else
    return "", false
  end
end

function locScale(num, lang)
  num=lang=="RU" and num*0.9-0.5 or num

  if (LOC) then
    return num/LOC.GetTextScale()
  else
    return num
  end
end

function roundNum(num, decPlaces)
  if (decPlaces and decPlaces>0) then
    if (num>=0) then
      return math.floor(num*10^decPlaces+0.5)/10^decPlaces
    else
      return math.ceil(num*10^decPlaces-0.5)/10^decPlaces
    end
  else
    if (num>=0) then
      return math.floor(num+0.5)
    else
      return math.ceil(num-0.5)
    end
  end
end

function replaceNaN(num) 
  if (tostring(num)==tostring((-1)^.5)) then
    return 0
  else
    return num
  end
end