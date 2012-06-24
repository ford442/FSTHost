/*
   Sysex praser - part of FSTHost
*/

#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <ctype.h>
#include <string.h>

#include "sysex.h"

// Send SysEx
SysExDumpV1*
sysex_dump_v1(
	uint8_t uuid,
	uint8_t program,
	uint8_t channel,
	uint8_t volume,
	enum SysExState state,
	char* name
) {
	SysExDumpV1* sysex = calloc(1, sizeof(SysExDumpV1));

	sysex->begin   = SYSEX_BEGIN;
	sysex->id      = SYSEX_MYID;
	sysex->version = SYSEX_VERSION;
	sysex->uuid    = uuid;
	sysex->program = program;
	sysex->channel = channel;
	sysex->volume  = volume;
	sysex->state   = state;
	sysex->end     = SYSEX_END;

	if ( (sysex->program & 0x80) ) {
		printf("SysEx - program - first byte can be set, this is not supported now :-(\n");
		free(sysex);
		return NULL;
	}

	short i;
	for (i=0; i < strlen(name) && i < sizeof(sysex->name) - 1; i++) {
		if ( ! isprint( toascii( name[i]) ) )
			continue;

		sysex->name[i] = name[i];
	} /* Last character of sysex->name remain 0 */

	return sysex;
}

SysExIdentReply*
sysex_ident_reply(uint8_t uuid)
{
	SysExIdentReply* sysex = calloc(1, sizeof(SysExIdentReply));

	sysex->begin	= SYSEX_BEGIN;
	sysex->type	= SYSEX_NON_REALTIME;
	sysex->target_id = 0x7F; // All Devices
	sysex->gi	= SYSEX_GENERAL_INFORMATION;
	sysex->ir	= SYSEX_IDENTITY_REPLY;
	sysex->id	= SYSEX_MYID;
	// sysex->family - not used now
	sysex->model[1]	= uuid;
	sysex->version[3] = SYSEX_VERSION;
	sysex->end	= SYSEX_END;

	return sysex;
}