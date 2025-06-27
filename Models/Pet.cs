namespace PetStoreAPI.Models
{
    public class Pet
    {
        public int PetId { get; set; }
        public string PetName { get; set; }
        public int PetStatus { get; set; }
        public int? PetStore { get; set; }
        public byte[]? PetImage { get; set; }
        public DateTime? RemovedAt { get; set; }
    }
} 