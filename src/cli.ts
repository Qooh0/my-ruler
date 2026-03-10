#!/usr/bin/env node
import { Command } from "commander";
import { syncCommand } from "./commands/sync";
import { applyCommand } from "./commands/apply";
import { revertCommand } from "./commands/revert";
import { newSkillCommand } from "./commands/new-skill";

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

program
  .command("new-skill <name>")
  .description("Scaffold a new skill template in templates/.ruler/skills/")
  .action(newSkillCommand);

program.parse(process.argv);