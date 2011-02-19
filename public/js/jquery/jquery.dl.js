jQuery.fn.extend({
	dts			:	function() {
						var matched = [], hasMatched = false;
						if(!$.isArray(this) && this.is('dd') ) {
							cur = this.prev();
							while(cur) {
								if ( cur.filter(function(){ return this.nodeType == 1; }) !== null && cur.is('dt') ) {
									matched = $.merge(matched,cur);
									hasMatched = true;
								} else if ( hasMatched == true ) {
									return $(matched.reverse());
								}
								cur = cur.prev();
							}
						}
						return $(matched.reverse());
					},
	dds			:	function() { 
						var matched = [], hasMatched = false;
						if(!$.isArray(this) && this.is('dt') ) {
							cur = this.next();
							while(cur) {
								if ( cur.filter(function(){ return this.nodeType == 1; }) !== null && cur.is('dd') ) {
									matched = $.merge(matched,cur);
									hasMatched = true;
								} else if ( hasMatched == true ) {
									return $(matched);
								}
								cur = cur.next();
							}
						}
						return matched;
					}
});
