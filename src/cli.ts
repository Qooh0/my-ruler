#!/usr/bin/env node
import { Command } from "commander";
import { syncCommand } from "./commands/sync";
import { applyCommand } from "./commands/apply";
import { revertCommand } from "./commands/revert";

const program = new Command();
program.name("my-ruler");

program
  .command("sync <target>")
  .description("Sync .ruler templates into target")
  .action(syncCommand);

program
  .command("apply <target>")
  .allowUnknownOption(true)
  .description("Run ruler apply in target")
  .action(applyCommand);

program
  .command("revert <target>")
  .allowUnknownOption(true)
  .description("Run ruler revert in target")
  .action(revertCommand);

program.parse(process.argv);