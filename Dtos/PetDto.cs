namespace PetStoreAPI.Dtos
{
    public class PetDto
    {
        public int PetId { get; set; }
        public string PetName { get; set; }
        public string PetStatus { get; set; }
        public string? PetStore { get; set; }
    }
} 