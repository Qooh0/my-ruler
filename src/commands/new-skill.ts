import path from "path";
import fs from "fs-extra";

const SKILL_NAME_PATTERN = /^[a-z][a-z0-9-]*$/;

const SKILL_TEMPLATE = (name: string) => `---
name: ${name}
description: TODO - Describe when this skill should be used
---

# ${name}

TODO: Write the skill instructions here.

## Guidelines

- Guideline 1
- Guideline 2
`;

export async function newSkillCommand(name: string) {
  if (!SKILL_NAME_PATTERN.test(name)) {
    console.error(
      "Error: Skill name must start with a lowercase letter and contain only lowercase letters, numbers, and hyphens."
    );
    process.exit(1);
  }

  const skillsDir = path.resolve(__dirname, "../../templates/.ruler/skills");
  const skillPath = path.join(skillsDir, name);

  if (await fs.pathExists(skillPath)) {
    console.error(`Error: Skill '${name}' already exists at ${skillPath}`);
    process.exit(1);
  }

  await fs.ensureDir(skillPath);
  await fs.writeFile(path.join(skillPath, "SKILL.md"), SKILL_TEMPLATE(name));

  console.log(`Created skill: templates/.ruler/skills/${name}/SKILL.md`);
  console.log("");
  console.log("Next steps:");
  console.log(`  1. Edit templates/.ruler/skills/${name}/SKILL.md`);
  console.log("  2. Run 'npm run build' to rebuild");
  console.log("  3. Run 'my-ruler sync <target>' to distribute");
}
