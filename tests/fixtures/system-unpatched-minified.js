'use strict';function render(){let o,s;const th=Object.keys(uci.get('luci','themes')||{}).sort();for(let t of th)
if(t.charAt(0)!='.')
o.value(uci.get('luci','themes',t),t);o=s.taboption('language',form.Flag,'_tablefilters',_('Table Filters'));o.default=o.disabled;o.uciconfig='luci';o.ucisection='main';o.ucioption='tablefilters';if(L.hasSystemFeature('sysntpd')){o=s.taboption('timesync',form.Flag,'enabled',_('Enable NTP client'));}return o;}
