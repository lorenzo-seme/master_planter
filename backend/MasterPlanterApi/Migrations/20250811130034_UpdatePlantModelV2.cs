using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MasterPlanterApi.Migrations
{
    /// <inheritdoc />
    public partial class UpdatePlantModelV2 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropPrimaryKey(
                name: "PK_Plants",
                table: "Plants");

            migrationBuilder.RenameColumn(
                name: "Room",
                table: "Plants",
                newName: "Username");

            migrationBuilder.RenameColumn(
                name: "Name",
                table: "Plants",
                newName: "PlantName");

            migrationBuilder.RenameColumn(
                name: "AdoptionDate",
                table: "Plants",
                newName: "PlantLocation");

            migrationBuilder.RenameColumn(
                name: "Id",
                table: "Plants",
                newName: "DateOfAdoption");

            migrationBuilder.AddColumn<string>(
                name: "PlantId",
                table: "Plants",
                type: "TEXT",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddPrimaryKey(
                name: "PK_Plants",
                table: "Plants",
                column: "PlantId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropPrimaryKey(
                name: "PK_Plants",
                table: "Plants");

            migrationBuilder.DropColumn(
                name: "PlantId",
                table: "Plants");

            migrationBuilder.RenameColumn(
                name: "Username",
                table: "Plants",
                newName: "Room");

            migrationBuilder.RenameColumn(
                name: "PlantName",
                table: "Plants",
                newName: "Name");

            migrationBuilder.RenameColumn(
                name: "PlantLocation",
                table: "Plants",
                newName: "AdoptionDate");

            migrationBuilder.RenameColumn(
                name: "DateOfAdoption",
                table: "Plants",
                newName: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_Plants",
                table: "Plants",
                column: "Id");
        }
    }
}
