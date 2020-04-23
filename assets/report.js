(function () {

    /**
     * Sets the initial sorting derived from the hash.
     *
     * @param linkelementids
     *          list of element ids to search for links to add sort inidcator
     *          hash links
     */
    function initialSort(linkelementids) {
        window.linkelementids = linkelementids;
        let hash = window.location.hash;
        if (hash) {
            let m = hash.match(/up-./);
            if (m) {
                let header = window.document.getElementById(m[0].charAt(3));
                if (header) {
                    sortColumn(header, true);
                }
                return;
            }
            m = hash.match(/dn-./);
            if (m) {
                let header = window.document.getElementById(m[0].charAt(3));
                if (header) {
                    sortColumn(header, false);
                }
                return
            }
        }
    }

    /**
     * Sorts the columns with the given header dependening on the current sort state.
     */
    function toggleSort(header) {
        let sortup = header.className.indexOf('down ') == 0;
        sortColumn(header, sortup);
    }

    /**
     * Sorts the columns with the given header in the given direction.
     */
    function sortColumn(header, sortup) {
        let table = header.parentNode.parentNode.parentNode;
        let body = table.tBodies[0];
        let colidx = getNodePosition(header);

        resetSortedStyle(table);

        let rows = body.rows;
        let sortedrows = [];
        for (let i = 0; i < rows.length; i++) {
            r = rows[i];
            sortedrows[parseInt(r.childNodes[colidx].id.slice(1))] = r;
        }

        let hash;

        if (sortup) {
            for (let i = sortedrows.length - 1; i >= 0; i--) {
                body.appendChild(sortedrows[i]);
            }
            header.className = 'up ' + header.className;
            hash = 'up-' + header.id;
        } else {
            for (let i = 0; i < sortedrows.length; i++) {
                body.appendChild(sortedrows[i]);
            }
            header.className = 'down ' + header.className;
            hash = 'dn-' + header.id;
        }

        setHash(hash);
    }

    /**
     * Adds the sort indicator as a hash to the document URL and all links.
     */
    function setHash(hash) {
        window.document.location.hash = hash;
        ids = window.linkelementids;
        for (let i = 0; i < ids.length; i++) {
            setHashOnAllLinks(document.getElementById(ids[i]), hash);
        }
    }

    /**
     * Extend all links within the given tag with the given hash.
     */
    function setHashOnAllLinks(tag, hash) {
        links = tag.getElementsByTagName("a");
        for (let i = 0; i < links.length; i++) {
            let a = links[i];
            let href = a.href;
            let hashpos = href.indexOf("#");
            if (hashpos !== -1) {
                href = href.substring(0, hashpos);
            }
            a.href = href + "#" + hash;
        }
    }

    /**
     * Calculates the position of a element within its parent.
     */
    function getNodePosition(element) {
        let pos = -1;
        while (element) {
            element = element.previousSibling;
            pos++;
        }
        return pos;
    }

    /**
     * Remove the sorting indicator style from all headers.
     */
    function resetSortedStyle(table) {
        for (let c = table.tHead.firstChild.firstChild; c; c = c.nextSibling) {
            if (c.className) {
                if (c.className.indexOf('down ') == 0) {
                    c.className = c.className.slice(5);
                }
                if (c.className.indexOf('up ') == 0) {
                    c.className = c.className.slice(3);
                }
            }
        }
    }

    window['initialSort'] = initialSort;
    window['toggleSort'] = toggleSort;

})();