using Microsoft.EntityFrameworkCore;
using MasterPlanterApi.Models;

namespace MasterPlanterApi.Data
{
	public class PlantContext : DbContext
	{
		public PlantContext(DbContextOptions<PlantContext> options) : base(options) { }

		public DbSet<Plant> Plants { get; set; }
	}
}