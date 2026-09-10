/* Copyright 2026 Gentoo Authors
 * Distributed under the terms of the GNU General Public License v2
 */

#include "bindings.h"

int main(void)
{
	SchemaBuilder *builder = schema_builder_new();
	if (!builder)
		return 1;

	char *error = 0;
	Schema *schema = schema_builder_build(builder, &error);
	return !schema || error;
}
