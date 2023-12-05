const ignoredEvent=function(){var e={},n,t;return function(i,p,r){t=new Date().getTime(),r=r||"ignored event",n=e[r]?t-e[r]:t,n>p&&(e[r]=t,i())}}(),overLappingSimp=function(e,n){var t=e.getBoundingClientRect(),i=n.getBoundingClientRect();return!(t.right<i.left||t.left>i.right||t.bottom<i.top||t.top>i.bottom)},overLapping=function(e,n){var t=e.getBoundingClientRect(),i=n.getBoundingClientRect();return overLappingSimp(e,n)&&(Math.abs(t.left-i.left)+Math.abs(t.right-i.right))/Math.max(t.width,i.width)<.5&&(Math.abs(t.bottom-i.bottom)+Math.abs(t.top-i.top))/Math.max(t.height,i.height)<.5};var searchIntersections=function(e){let n,t=e;for(;t;){if(t.classList.contains("typst-group")){n=t;break}t=t.parentElement}if(!t){console.log("no group found");return}const p=n.children,r=p.length,w=[];for(let u=0;u<r;u++){const h=p[u];overLapping(h,e)&&w.push(h)}return w};const gr=window.typstGetRelatedElements=function(e){let n=e.relatedElements;return n==null&&(n=e.relatedElements=searchIntersections(e)),n},getRelatedElements=function(e){return gr(e.target)};var linkmove=function(e){ignoredEvent(function(){const n=getRelatedElements(e);if(n!=null)for(var t=0;t<n.length;t++){var i=n[t];i.classList.contains("hover")||i.classList.add("hover")}},200,"mouse-move")},linkleave=function(e){const n=getRelatedElements(e);if(n!=null)for(var t=0;t<n.length;t++){var i=n[t];i.classList.contains("hover")&&i.classList.remove("hover")}};function findAncestor(e,n){for(;e&&!e.classList.contains(n);)e=e.parentElement;return e}function findGlyphListForText(e){const n=findAncestor(e,"typst-text");if(n)return Array.from(n.children).filter(t=>t.tagName==="use")}function nextNode(e){if(e.hasChildNodes())return e.firstChild;for(;e&&!e.nextSibling;)e=e.parentNode;return e?e.nextSibling:null}function getRangeSelectedNodes(e,n){var t=e.startContainer,i=e.endContainer;if(t==i){if(n(t))return[t];if(n(t.parentElement))return[t.parentElement]}for(var p=[];t&&t!=i;)t=nextNode(t),n(t)&&p.push(t);for(t=e.startContainer;t&&t!=e.commonAncestorContainer;)n(t)&&p.unshift(t),t=t.parentNode;return p}function getSelectedNodes(e){if(window.getSelection){var n=window.getSelection();if(!n.isCollapsed){if(n.rangeCount===1)return getRangeSelectedNodes(n.getRangeAt(0),e);let t=[];for(let i=0,p=n.rangeCount;i<p;i++)t.push(...getRangeSelectedNodes(n.getRangeAt(i),e));return t}}return[]}function getGlyphLenShape(e){return e.map(n=>{const t=n.getAttribute("href"),i=document.getElementById(t.slice(1));return 1+Number.parseInt(i?.getAttribute("data-liga-len")||"0")})}function getGlyphAdvanceShape(e){return e.map(n=>Number.parseInt(n.getAttribute("x")||"0"))}function adjsutTextSelection(e,n){e.addEventListener("copy",s=>{const d=getSelectedNodes(f=>f.classList?.contains("tsel")||f.classList?.contains("tsel-tok")||f.classList?.contains("typst-content-hint")),a=[];let o=!1;for(let f of d)if(f.classList.contains("tsel"))f.hasAttribute("data-typst-layout-checked")||a.push(f.textContent),o=!0;else if(f.classList.contains("tsel-tok"))a.push(f.textContent);else if(o){const x=String.fromCodePoint(Number.parseInt(f.getAttribute("data-hint")||"0",16))||`
`;a.push(x),o=!0}const E=a.join("").replace(/\u00a0/g," ");console.log("user copy",E),navigator?.clipboard?navigator.clipboard.writeText(E):s.clipboardData.setData("text/plain",E),s.preventDefault()});const t=s=>s.nodeType===Node.TEXT_NODE?s.parentElement:s,i=s=>{const d=t(s);return d?.classList?.contains("tsel")?d:void 0},p=(s,d)=>{const a=document.createElement("div"),o=d.getBoundingClientRect();a.style.position="absolute",a.style.float="left",a.style.left=`${o.left+window.scrollX}px`,a.style.top=`${o.top+window.scrollY}px`,a.style.width=`${o.width}px`,a.style.height=`${o.height}px`,a.style.backgroundColor="#7db9dea0",s.appendChild(a)},r=s=>{s&&(s.innerHTML="")};let w=!1;window.addEventListener("mousedown",s=>{s.button===0&&(w=!0)}),window.addEventListener("mouseup",s=>{s.button===0&&(w=!1)}),e.addEventListener("mousemove",s=>{w&&ignoredEvent(()=>{u(s)},2,"doc-text-sel")});function u(s){s.target?.classList.contains("tsel-tok")||h(!0,s)}document.addEventListener("selectionchange",()=>h(!1));function h(s,d){const a=window.getSelection();let o=document.getElementById("tsel-sel-box");if(!a?.rangeCount){r(o);return}const E=a.getRangeAt(0),f=a.getRangeAt(a.rangeCount-1);if(!E||!f)return;const x=l=>l?.classList.contains("text-guard")||l?.classList.contains("typst-page")||l?.classList.contains("typst-search-hint"),C=x(t(E.startContainer)),b=x(t(f.endContainer));if(C||b){console.log("page guard selected"),C&&b&&r(o);return}r(o),o||(o=document.createElement("div"),o.id="tsel-sel-box",o.style.zIndex="100",o.style.position="absolute",o.style.pointerEvents="none",o.style.left="0",o.style.top="0",o.style.float="left",document.body.appendChild(o));const S=i(E.startContainer),R=i(f.endContainer),T=getSelectedNodes(l=>l.classList?.contains("tsel")||l.classList?.contains("typst-search-hint")||l.classList?.contains("tsel-tok")),L=new Range,A=(l,c)=>{L.setStartBefore(l),L.setEndAfter(c),p(o,L)},y=new Map;for(let l of T)if(l.classList.contains("tsel-tok")){const c=l.parentElement,g=Array.from(c.children).indexOf(l);if(!y.has(c))y.set(c,[g,g]);else{const[m,v]=y.get(c);y.set(c,[Math.min(m,g),Math.max(v,g)])}}else if(l.classList.contains("tsel")&&!l.hasAttribute("data-typst-layout-checked")){const c=l===S?E.startOffset:0,g=l===R?f.endOffset-1:-1;y.set(l,[c,g])}if(s){let l=1e11,c=-1;for(const g of y.keys()){const m=g.getAttribute("data-selection-index");if(!m)continue;const v=Number.parseInt(m);l=Math.min(l,v),c=Math.max(c,v)}if(c!==-1){const g=d.clientX,m=d.clientY,v=n.flow;for(;;){const k=v[c],N=k.getBoundingClientRect();if((g>N.right||m>N.bottom)&&(y.set(k,[0,-1]),c+1<v.length)){c+=1;const M=v[c],P=M.getBoundingClientRect();if(N.bottom>P.top&&N.top<P.bottom){console.log("same line",k,M);continue}}break}}}for(let[l,[c,g]]of y){const m=findGlyphListForText(l);if(!m?.length)continue;if(c===0&&g===-1){A(m[0],m[m.length-1]);continue}const v=getGlyphLenShape(m),k=P=>{let G=0;for(let B=0;B<v.length;B++){if(G+v[B]>P)return m[B];G+=v[B]}};let N=m[0];c!==0&&(N=k(c)||N);let M=m[m.length-1];g!==-1&&(M=k(g)||M),A(N,M)}}}function createPseudoText(e){const n=document.createElementNS("http://www.w3.org/2000/svg","foreignObject");n.setAttribute("width","1"),n.setAttribute("height","1"),n.setAttribute("x","0"),n.setAttribute("y","0");const t=document.createElement("span");return t.textContent="&nbsp;",t.style.width=t.style.height="100%",t.style.textAlign="justify",t.style.opacity="0",t.classList.add(e),n.append(t),n}window.typstProcessSvg=function(e,n){let t={flow:[]};for(var i=e.getElementsByClassName("pseudo-link"),p=0;p<i.length;p++){var r=i[p];r.addEventListener("mousemove",linkmove),r.addEventListener("mouseleave",linkleave)}const w=n?.layoutText??!0;if(w&&(setTimeout(()=>{const u=document.createElement("style");u.innerHTML=`.tsel { font-family: monospace; text-align-last: left !important; -moz-text-size-adjust: none; -webkit-text-size-adjust: none; text-size-adjust: none; }
.tsel span { float: left !important; position: absolute !important; width: fit-content !important; top: 0 !important; }
.typst-search-hint { font-size: 2048px; color: transparent; width: 100%; height: 100%; }
.typst-search-hint { color: transparent; user-select: none; }
.typst-search-hint::-moz-selection { color: transparent; background: #00000001; }
.typst-search-hint::selection { color: transparent; background: #00000001; }
.tsel span::-moz-selection,
.tsel::-moz-selection {
  background: transparent !important;
}
.tsel span::selection,
.tsel::selection {
  background: transparent !important;
} `,document.getElementsByTagName("head")[0].appendChild(u);const h=window.devicePixelRatio||1;e.style.setProperty("--typst-font-scale",h.toString()),window.addEventListener("resize",()=>{const s=window.devicePixelRatio||1;e.style.setProperty("--typst-font-scale",s.toString())}),window.layoutText(e,t)},0),adjsutTextSelection(e,t)),e.addEventListener("click",u=>{let h=u.target;for(;h;){const s=h.getAttribute("data-span");if(s){console.log("source-span of this svg element",s);const d=document.body||document.firstElementChild,a=d.getBoundingClientRect(),o=window.innerWidth||0,E=u.clientX-a.left+.015*o,f=u.clientY-a.top+.015*o;triggerRipple(d,E,f,"typst-debug-react-ripple","typst-debug-react-ripple-effect .4s linear");return}h=h.parentElement}}),w&&e.querySelectorAll(".typst-page").forEach(u=>{u.prepend(createPseudoText("text-guard"))}),window.location.hash){const h=window.location.hash.split("-");if(h.length===2&&h[0]==="#loc"){const s=h[1].split("x");if(s.length===3){const d=Number.parseInt(s[0]),a=Number.parseFloat(s[1]),o=Number.parseFloat(s[2]);window.handleTypstLocation(e,d,a,o)}}}},window.layoutText=function(e,n){const t=Array.from(e.querySelectorAll(".tsel"));n.flow=t;const i=performance.now(),p=document.createElementNS("http://www.w3.org/1999/xhtml","canvas").getContext("2d");p.font="128px sans-serif";const r=p.measureText("A").width,w=[],u=(s,d)=>{const a=t.slice(s,d);s-=1;for(let o of a)if(s+=1,!o.getAttribute("data-typst-layout-checked")&&(o.setAttribute("data-selection-index",s.toString()),o.setAttribute("data-typst-layout-checked","1"),o.style.fontSize)){const E=o.parentElement,f=o.innerText,x=E.cloneNode(!0),C=x.firstElementChild;C&&(C.className="typst-search-hint"),E.parentElement.insertBefore(x,E),w.push([o,f]);const b=f.length,S=findGlyphListForText(o);if(!S)continue;const R=getGlyphLenShape(S),T=getGlyphAdvanceShape(S).map(c=>c/16);let L=!1;const A=[];let y=0,l=0;for(let c of f){if(y>=T.length){L=!0;break}let g=T[y];R[y]>1&&(g+=l*r),l++,l>=R[y]&&(y++,l=0);const m=document.createElement("span");m.textContent=c,m.classList.add("tsel-tok"),m.style.left=`${g}px`,A.push(m)}if(L)continue;o.innerHTML="",o.append(...A)}console.log(`layoutText ${t.length} elements used since ${performance.now()-i} ms`)},h=100;for(let s=0;s<t.length;s+=h){const d=s;setTimeout(()=>{u(d,d+h)})}},window.handleTypstLocation=function(e,n,t,i,p){const r=p?.behavior||"smooth",w=window.assignSemaHash||((d,a,o)=>{location.hash=`loc-${d}x${a.toFixed(2)}x${o.toFixed(2)}`}),u=findAncestor(e,"typst-doc");if(!u){console.warn("no typst-doc found",e);return}const h=u.children;let s=0;for(let d=0;d<h.length;d++)if(h[d].tagName==="g"&&s++,s==n){const a=window.innerWidth*.01,o=window.innerHeight*.01,E=h[d],f=Number.parseFloat(u.getAttribute("data-width")||u.getAttribute("width")||"0")||0,x=Number.parseFloat(u.getAttribute("data-height")||u.getAttribute("height")||"0")||0,C=u.getBoundingClientRect(),b={left:C.left,top:C.top,width:C.width,height:C.height},S=7*a,R=38.2*o,T=E.transform.baseVal.consolidate()?.matrix;T&&(b.left+=T.e/f*b.width,b.top+=T.f/x*b.height);const L=document.body||document.firstElementChild,A=L.getBoundingClientRect(),y=b.left-A.left+t/f*b.width-S,l=b.top-A.top+i/x*b.height-R,c=y+S,g=l+R;window.scrollTo({behavior:r,left:y,top:l}),r!=="instant"&&triggerRipple(L,c,g,"typst-jump-ripple","typst-jump-ripple-effect .4s linear"),w(s,t,i);return}};function triggerRipple(e,n,t,i,p){const r=document.createElement("div");r.className=i,r.style.left=`${n}px`,r.style.top=`${t}px`,e.appendChild(r),r.style.animation=p,r.onanimationend=()=>{e.removeChild(r)}}var scriptTag=document.currentScript;if(scriptTag){const e=findAncestor(scriptTag,"typst-doc");e&&window.typstProcessSvg(e)}
