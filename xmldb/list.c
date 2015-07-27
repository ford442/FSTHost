#include <stdlib.h>
#include <string.h>
#include <libxml/parser.h>
#include <libxml/tree.h>

#define DEFAULT_APPNAME "fsthost"

char* fst_info_default_path() {
	const char* henv = getenv("HOME");
	size_t len = strlen(henv) + strlen(DEFAULT_APPNAME) + 7;
	char* dbif = malloc(len);
	snprintf(dbif, len, "%s/.%s.xml", henv, DEFAULT_APPNAME);
	return dbif;
}

xmlDoc* fst_info_read_xmldb ( const char* dbpath ) {
	xmlDoc* xml_db;
	xmlKeepBlanksDefault(0);
	if ( dbpath ) {
		xml_db = xmlReadFile(dbpath, NULL, 0);
	} else {
		char* defpath = fst_info_default_path();
		xml_db = xmlReadFile(defpath, NULL, 0);
		free ( defpath );
	}
	return xml_db;
}

int fst_info_list(const char* dbpath, const char* arch) {
	xmlDoc* xml_db = fst_info_read_xmldb ( dbpath );
	if (!xml_db) return 1;

	xmlNode* xml_rn = xmlDocGetRootElement(xml_db);
	xmlNode* n;
	for (n = xml_rn->children; n; n = n->next) {
		if (xmlStrcmp(n->name, BAD_CAST "fst")) continue;

		xmlChar* p = xmlGetProp(n, BAD_CAST "path");
		xmlChar* a = xmlGetProp(n, BAD_CAST "arch");
		xmlChar* f = NULL;

		if ( arch != NULL && xmlStrcmp(a, BAD_CAST arch) != 0 )
			continue;

		xmlNode* nn;
		for (nn = n->children; nn; nn = nn->next) {
			if (xmlStrcmp(nn->name, BAD_CAST "name") == 0) {
				f = nn->children->content;
				break;
			}
		}
		if ( f == NULL ) continue;

		if ( arch == NULL )
			printf("%s|%s|%s\n", f, a, p);
		else
			printf("%s|%s\n", f, p);
	}

	xmlFreeDoc(xml_db);
	return 0;
}
