import path from "path";
import fs from "fs-extra";
import fg from "fast-glob";

export async function syncCommand(target: string) {
  const targetRoot = path.resolve(target);
  const templateBase = path.resolve(__dirname, "../../templates");
  const templateRoot = path.join(templateBase, ".ruler");
  const destRoot = path.join(targetRoot, ".ruler");

  const copied: string[] = [];
  const skipped: string[] = [];
  const errors: string[] = [];

  try {
    await fs.ensureDir(destRoot);

    // ruler.toml
    await fs.copy(
      path.join(templateRoot, "ruler.toml"),
      path.join(destRoot, "ruler.toml"),
      { overwrite: true }
    );
    copied.push("ruler.toml");

    // skills
    await fs.copy(
      path.join(templateRoot, "skills"),
      path.join(destRoot, "skills"),
      { overwrite: true }
    );
    copied.push("skills/**");

    // agents
    const agents = await fg("agents/*.md", { cwd: templateRoot });
    await fs.ensureDir(path.join(destRoot, "agents"));

    for (const file of agents) {
      const src = path.join(templateRoot, file);
      const dst = path.join(destRoot, file);
      if (await fs.pathExists(dst)) {
        skipped.push(file);
        continue;
      }
      await fs.copy(src, dst);
      copied.push(file);
    }

    // .claude/settings.json
    const claudeTemplateDir = path.join(templateBase, ".claude");
    const claudeDestDir = path.join(targetRoot, ".claude");
    const settingsFile = "settings.json";
    const settingsSrc = path.join(claudeTemplateDir, settingsFile);
    const settingsDst = path.join(claudeDestDir, settingsFile);

    if (await fs.pathExists(settingsSrc)) {
      await fs.ensureDir(claudeDestDir);
      if (await fs.pathExists(settingsDst)) {
        skipped.push(".claude/settings.json");
      } else {
        await fs.copy(settingsSrc, settingsDst);
        copied.push(".claude/settings.json");
      }
    }
  } catch (e: any) {
    errors.push(e.message);
  }

  console.log("Copied:", copied);
  console.log("Skipped (exists):", skipped);
  if (errors.length) console.error("Errors:", errors);
}