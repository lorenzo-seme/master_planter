using System.ComponentModel.DataAnnotations;

namespace MasterPlanterApi.Models
{
	public class Plant
	{
		[Key]
		public string PlantId { get; set; }               // plant identifier
		
		public string Username { get; set; }       // user identifier
		public string PlantName { get; set; }          // name of the plant
		public string DateOfAdoption { get; set; } // date the plant was bought
		public string PlantLocation { get; set; }          // Room or spot the plant is located
	}
}
